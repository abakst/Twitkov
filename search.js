myget = new XMLHttpRequest();


myget.onreadystatechange = function() {
   if (myget.readyState == 4 && myget.status==200) {
       document.getElementById:w 
   }
}
    
myget.open("GET", "http://search.twitter.com/search.json?q=stealthmountain", true);
myget.send();
