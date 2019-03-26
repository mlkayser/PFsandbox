({
    handleClick : function(cmp, event) {
        var urlValue = cmp.get("v.url");
        console.log("url: " + urlValue);
        if (urlValue.includes('@')) {
            urlValue = "mailto:" + urlValue;
            //location.href = "mailto:" + urlValue;
        }           
        console.log("url: " + urlValue);
        //window.location.href = urlValue;
        sforce.one.navigateToURL(urlValue);
    }
})