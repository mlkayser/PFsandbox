({
    getClubStatus : function(component, event, helper) {
        var status = helper.getQueryVariable('status');
        console.log('STATUS=' + status);
        component.set("v.status", status);
    },
})