({
    helperMethod : function() {

    },

    svgRender: function(component, svgId) {
        console.log('svgRender() component: ', component, 'sgvId: ', svgId);
        var svg = component.find(svgId);
        var value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value;
    }
})