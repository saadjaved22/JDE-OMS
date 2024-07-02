({
    getIERRec : function(component) {
        var action = component.get("c.lightningIER");
        var recordId = component.get('v.recordId');
        action.setParams({accId: recordId});
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                console.log(rtnValue);
                window.scrollTo(0,0);
                console.log(rtnValue);
                component.set("v.data",rtnValue);
            } else {
                
            }
        });
        $A.enqueueAction(action);
    }
})