({
	helperMethod : function() {
		
	},
	svgRender: function(component) {
        console.log('svgRender() component: ', component);
        var svgList = component.find("icon-svg");

        for(var i = 0; i < svgList.length; i++) {
            console.log('SVG:' + svgList[i]);
            var value = svgList[i].getElement().innerText;
            value = value.replace("<![CDATA[", "").replace("]]>", "");
            svgList[i].getElement().innerHTML = value;
        }

    }
})