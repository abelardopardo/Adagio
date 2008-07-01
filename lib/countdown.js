//start
// NOTE: the month entered must be one less than current month. ie; 0=January, 11=December
// NOTE: the hour is in 24 hour format. 0=12am, 15=3pm etc
// format: dateFuture = new Date(year,month-1,day,hour,min,sec)
// example: dateFuture = new Date(2003,03,26,14,15,00) = April 26, 2003 - 2:15:00 pm

// dateFuture = new Date(2006,10,10,10,0,55);

function GetCount(){
    dateNow = new Date();                               //grab current date
    amount = dateFuture.getTime() - dateNow.getTime(); //calc milliseconds between dates
    delete dateNow;

    countElement = document.getElementById('countbox');

    // time is already past
    if(amount > 0){
        days=0;hours=0;mins=0;secs=0;out="";
        //kill the "milliseconds" so just secs
        amount = Math.floor(amount/1000);
        days=Math.floor(amount/86400);
        amount=amount%86400;
        hours=Math.floor(amount/3600);
        amount=amount%3600;
        mins=Math.floor(amount/60);
        amount=amount%60;
        secs=Math.floor(amount);
	if (document.getElementById('countbox').lang == "es") {
          if(days != 0){out += days +" día"+((days!=1)?"s":"")+", ";}
          if(days != 0 || hours != 0){out += hours +" hora"+((hours!=1)?"s":"")+", ";}
          if(days != 0 || hours != 0 || mins != 0){out += mins +" minuto"+((mins!=1)?"s":"")+", ";}
          out += secs +" segundos";
        } else {
          if(days != 0){out += days +" day"+((days!=1)?"s":"")+", ";}
          if(days != 0 || hours != 0){out += hours +" hour"+((hours!=1)?"s":"")+", ";}
          if(days != 0 || hours != 0 || mins != 0){out += mins +" minute"+((mins!=1)?"s":"")+", ";}
          out += secs +" seconds";
        }
        countElement.innerHTML=countElement.attributes['class'].nodeValue + " " + out;
        setTimeout("GetCount()", 1000);
    } else {
	countElement.innerHTML="";
    }
}
//call when everything has loaded
window.onload=function(){GetCount();}
//
