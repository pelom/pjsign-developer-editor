({
// Your renderer method overrides go here
    afterRender: function(component, helper) {
        this.superAfterRender();
        console.log('afterRender() component: ' + component);
        helper.svgRender(component);
    }
})