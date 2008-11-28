/*
 * Copyright (C) 2008 Carlos III University of Madrid
 * This file is part of the ADA: Agile Distributed Authoring Toolkit

 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor
 * Boston, MA  02110-1301, USA.

 * Class to shuffle the QandA elements of a DocBook XML file. The main usage of
 * this class is to create different versions of an exam in which questions are
 * labeled with the QandA elements of Docbook. The resulting files contain the
 * same questions but randomly shuffled. The program also prints the
 * correspondence between the questions of the generated shuffled files.
 *
 * @author Abelardo Pardo (abel@it.uc3m.es)
 * 
 * @version $Id$
 *
 * Copyright: This file was created at the Carlos III University of Madrid.
 * Carlos III University of Madrid makes no warranty about the suitability of
 * this software for any purpose. It is presented on an AS IS basis.
 *
 */

import java.util.*;
import java.text.DecimalFormat;
import java.io.*;
import org.jdom.*;
import org.jdom.output.Format;
import es.uc3m.it.gol.XMLMgr;

/**
 * 
 * Class to shuffle questions in an exam written in docbook. The procedure
 * shuffles all qandaset as well as all internal qandaentry (when there is more
 * than one).
 *
 * @author Abelardo Pardo (abel@it.uc3m.es)
 *
 * @version $Id: Shuffle.java,v 1.3 2005/09/16 14:05:35 abel Exp $
 */
public class Shuffle {
    static Random rnd;

    public Shuffle() {}

    public static void main(String[] args) throws Exception {
	XMLMgr docMgr;      // Handle the XML document
	File in;
	Element root;
	Element qandaset;
	Element sectionInfo;
	List seedList;
	Vector[] permutations;
	Hashtable qandadivIndex;
	int versions;
	int index;
	int stepCount;

	stepCount = 1;

	// Check that the number of arguments is correct
	if (args.length != 1) {
	    System.out.println("Incorrect parameter number. A file is required.");
	    System.out.println("File must be in DocBook with QandADivs and QandAEntries.");
	    return;
	}

	System.out.println("Step " + stepCount++ + ": Open the file and check permissions");

	// Open the file and make sure it exists and can be read
	in = new File(args[0]);
	if (!in.exists() || !in.canRead()) {
	    System.out.println("Unable to open/read file " + args[0] + ".");
	    return;
	}

	System.out.println("Step " + stepCount++ + ": Create the XML document manager");

	// Create the document manager
	docMgr = new XMLMgr();
	try {
	    docMgr.parseFile(args[0]);
	} catch (Exception e) {
	    System.out.println("Error while parsing file.");
	    return;
	}
	
	System.out.println("Step " + stepCount++ + ": Fetch and check root element.");

	// Fetch the root element
	root = docMgr.getRootElement();
	if (root == null) {
	    System.out.println("Null root element after parse.");
	    return;
	}

	System.out.println("Step " + stepCount++ + ": Check the presence of 'status' attribute.");

	// Check if there is a seed attribute stored as "status"
	if (root.getAttribute("status") != null) {
	    System.out.println("File contains seed attribute as status. Ignoring.");
	    return;
	}

	System.out.println("Step " + stepCount++ + ": Fetch the sectioninfo element or create one");

	// Fetch the sectioninfo element or create one
	seedList = new LinkedList();
	sectionInfo = root.getChild("sectioninfo");
	if (sectionInfo != null) {
	    List pnumbers;
	    pnumbers = sectionInfo.getChildren("productnumber");
	    if (pnumbers != null) {
		// Create a list of productnumber elements - seeds for rnd
		for (ListIterator li = pnumbers.listIterator(); li.hasNext();) {
		    seedList.add(((Element)li.next()).clone());
		} // End of foreach productnumber element
	    } // End if productnumber is not empty
	    System.out.println("Step " + stepCount++ + ": Read " +
			       pnumbers.size() + " seeds in document.");

	} // If sectionInfo is not null

	System.out.println("Step " + stepCount++ + ": Fetch the qandadiv elements to shuffle");

	// If no info has been given to produce a seed, create one within its
	// corresponding productnumber element
	if (seedList.size() == 0) {
	    Element toAdd;

	    toAdd = new Element("productnumber");
	    toAdd = toAdd.setText((new Long(System.currentTimeMillis())).toString());
	    seedList.add(toAdd);
	} 

	// fetch the quandaset element that contains the elements to be shuffled
	qandaset = root.getChild("qandaset");
	if (qandaset == null) {
	    System.out.println("No element qandaset found under root.");
	    return;
	}
	root.removeChild("qandaset");

	if (qandaset.getChildren("qandadiv") == null) {
	    System.out.println("No qandadiv elements found. Nothing to shuffle.");
	    return;
	}
	
	System.out.println("Step " + stepCount++ + ": Creating hash for " + 
			   qandaset.getChildren("qandadiv").size() + " qandadivs");

	// Create the qandadiv/qandaentry -> index hash
	qandadivIndex = new Hashtable();
	index = 1;
	System.out.print("IDs: ");
	for (ListIterator li = qandaset.getChildren("qandadiv").listIterator();
	     li.hasNext();) {
	    Element qandadiv;

	    qandadiv = (Element)li.next();
	    
	    if (qandadiv.getChildren("qandaentry").size() > 1) {
		int entryIdx;

		entryIdx = 1;
		for (ListIterator li2 = qandadiv.getChildren("qandaentry").listIterator(); 
		     li2.hasNext();) {
		    Element qandaentry;
		    
		    qandaentry = (Element)li2.next();
		    qandadivIndex.put(qandaentry, new Integer(index++));
		    System.out.print(qandadiv.getAttributeValue("id") + "," +
				     entryIdx + ";");
		    entryIdx++;
		}
	    } else {
		qandadivIndex.put(qandadiv, new Integer(index++));
		System.out.print(qandadiv.getAttributeValue("id") + ";");
	    }
	}
	System.out.println();
	
	
	System.out.println("Step " + stepCount++ + ": Hash with " + (index - 1) + " elements.");
	System.out.println("Step " + stepCount++ + ": Create the permutation vectors.");

	// Create the space for permutations
	permutations = new Vector[seedList.size()];
	for (int i = 0; i < seedList.size(); i++) {
	    permutations[i] = new Vector();
	}

	System.out.println("Step " + stepCount++ + ": Shuffle elements.");

	// Loop over versions
	for (int i = 1; i <= seedList.size(); i++) {
	    Vector sectionChild;
	    List entries;
	    long seed;

	    // Obtain and set the seed
	    try {
		seed = Long.decode(((Element)seedList.get(i - 1)).getTextTrim()).longValue();
	    } catch (NumberFormatException e) {
		System.out.println("Value " + 
				   ((Element)seedList.get(i - 1)).getTextTrim() +
				   " not valid as seed number.");
		return;
	    }
	    rnd = new Random(seed);

	    // Add the seed value as status attribute of the root element
	    root.setAttribute(new Attribute("status", String.valueOf(seed)));

	    // Add the sectioninfo with the productnumber element
	    root.removeContent(sectionInfo);
	    sectionInfo = new Element("sectioninfo");
	    sectionInfo = sectionInfo.addContent((Element)seedList.get(i - 1));
	    sectionChild = new Vector();
	    sectionChild.add(sectionInfo);
	    root.addContent(0, sectionChild);

	    // Remove the qandaset from the document
	    qandaset.detach();
	    entries = new ArrayList();

	    // Transfer qandadiv to another list
	    for (ListIterator li = qandaset.getChildren("qandadiv").listIterator(); 
		 li.hasNext();) {
		Element point;

		point = (Element)li.next();
		entries.add(point);
	    }
	    // Remove qandadivs
	    qandaset.removeChildren("qandadiv");

	    // Here is where the shuffling is done
	    while (entries.size() > 0) {
		Element point; 
		
		// Remove a random element
		point = (Element)entries.remove(rnd.nextInt(entries.size()));

		// Effectively detach this from quandaset
		point.detach();
		
		// If it is a qandadiv with more than one qandaentry, then
		// shuffle the internal qandaentries
		if (point.getChildren("qandaentry").size() > 1) {
		    shuffleDiv(point, permutations[i - 1], qandadivIndex);
		} else {
		    permutations[i - 1].add(qandadivIndex.get(point));
		}

		// Insert it in the new list
		qandaset.addContent(point);
	    } // End of while

	    root.addContent(qandaset);

	    // Dump the result 
	    docMgr.writeFile(args[0].replaceAll(".xml$", "_" + i + ".xml"),
			     Format.getRawFormat());
	} // End of for i = 1 to number of versions to produce

	System.out.println("Step " + stepCount++ + ": Dumping all permutations");
	System.out.println();

	// Loop over all the permutations
	for (int i = 0; i < permutations.length; i++) {
	    for (int j = 0; j < i + 1; j++) {
		dumpPermutation(permutations, j - 1, i);
	    }
	}
    } // End of main

    public static void dumpPermutation(Vector[] permutations, int idxA, int idxB) {
	DecimalFormat dfmt;
	
	// if idxA, then first permutation is the identity.

	dfmt = new DecimalFormat("00");

	if (idxA == -1) {
	    System.out.print("Src: ");
	} else {
	    System.out.print("V" + dfmt.format((long)idxA) + ": ");
	}

	// Dump the succesive indeces
	for (int j = 0; j < permutations[idxB].size(); j++) {
	    System.out.print(dfmt.format((long)j + 1) + " ");
	}
	System.out.println();
	
	//  A->B
	System.out.print("V" + dfmt.format((long)idxB) + ": ");
	for (int j = 0; j < permutations[idxB].size(); j++) {
	    if (idxA == -1) { 
		// This line is buggy. Needs a fix, but I don't know how to do
		// it.a
		System.out.print(dfmt.format(permutations[idxB].elementAt(j)) + " ");
	    } else {
		System.out.print(dfmt.format((long)permutations[idxB].indexOf(permutations[idxA].elementAt(j)) + 1) + " ");
	    }
	}
	System.out.println();
	
	//  B->A
	System.out.print("Rev: ");
	for (int j = 0; j < permutations[idxB].size(); j++) {
	    if (idxA == -1) {
		System.out.print(dfmt.format((long)permutations[idxB].indexOf(new Integer(j + 1)) + 1) + " ");
	    } else {
		System.out.print(dfmt.format((long)permutations[idxA].indexOf(permutations[idxB].elementAt(j)) + 1) + " ");
	    }
	}
	System.out.println();
	
	
	System.out.println();
    }

    public static void shuffleDiv(Element qandadiv, Vector permutation,
				  Hashtable qandadivIndex) {
	List entries;

	entries = new ArrayList();
	for (ListIterator li = qandadiv.getChildren("qandaentry").listIterator(); 
	     li.hasNext();) {
	    Element point;
	    
	    point = (Element)li.next();
	    entries.add(point);
	}
	// Remove quandaentries
	qandadiv.removeChildren("qandaentry");

	// Here is where the shuffling is done
	while (entries.size() > 0) {
	    Element point; 
	    
	    // Remove a random element
	    point = (Element)entries.remove(rnd.nextInt(entries.size()));
	    // Effectively detach this from qandadiv
	    point.detach();
	    
	    // Insert it in the element
	    qandadiv.addContent(point);

	    // Upate the permutation vector
	    permutation.add(qandadivIndex.get(point));
	} // End of while
    } // End of ShuffleDiv
} // End of class
