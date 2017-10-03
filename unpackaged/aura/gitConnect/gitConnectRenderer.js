({
	// Your renderer method overrides go here
    afterRender: function(component, helper) {
        this.superAfterRender();

        console.log('afterRender() component: ' + component);

        var svgList = component.get("v.svgList");
        for(var i = 0; i < svgList.length; i++) {
            helper.svgRender(component, svgList[i]);
        }
    }
})