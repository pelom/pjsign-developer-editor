({
    afterRender: function(component, helper) {
        console.log('Olá');
        var svg = component.find("svg_content");
        var value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value;
    }
})