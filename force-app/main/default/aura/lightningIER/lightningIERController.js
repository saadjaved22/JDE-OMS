({
  init: function (cmp, event, helper) {
    console.log("lightning IER init");

    cmp.set("v.columns", [
      { label: "Name", fieldName: "Name", type: "text" },
      { label: "Subject Line", fieldName: "SubjectLine", type: "text" },
      { label: "From Name", fieldName: "FromName", type: "text" },
      { label: "From Address", fieldName: "FromAddress", type: "text" },
      { label: "Date Sent", fieldName: "DateSentSTR", type: "text" },
      { label: "Date Opened", fieldName: "DateOpened", type: "text" },
      {
        label: "Hard Bounce",
        fieldName: "HardBounceSTR",
        type: "text",
        cellAttributes: { alignment: "center" }
      },
      { label: "Journey Name", fieldName: "JourneyName", type: "text" }
    ]);

    helper.getIERRec(cmp);
  }
});
