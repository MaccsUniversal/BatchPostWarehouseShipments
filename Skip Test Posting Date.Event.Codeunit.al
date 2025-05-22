codeunit 50103 "Skip Test Posting Date - WBP"
{
    EventSubscriberInstance = Manual;

    var
        BatchPost: Boolean;

    procedure SetParameter(var BatchPost: Boolean): Boolean
    begin
        this.BatchPost := BatchPost;
    end;

    procedure GetParameter() Result: Boolean
    begin
        Result := this.BatchPost;
        exit(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnValidatePostingAndDocumentDateOnBeforeTestPostingDate, '', true, true)]
    local procedure SetSkipTestPostingDate(var SkipTestPostingDate: Boolean)
    begin
        if GetParameter() then
            SkipTestPostingDate := true;
    end;
}