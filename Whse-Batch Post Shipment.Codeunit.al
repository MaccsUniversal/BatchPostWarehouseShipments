
codeunit 50100 "Whse.-Batch Post Shipment"
{
    EventSubscriberInstance = Manual;

    var
        ShipandInvoice: Boolean;
        BatchPost: Boolean;
        ShipmentCount: Integer;
        ShipmentCountTotal: Integer;
        WhseShptHdr: Record "Warehouse Shipment Header";


    procedure SetParameters(BatchPost: Boolean; var ShipandInvoice: Boolean)
    begin
        this.BatchPost := BatchPost;
        this.ShipandInvoice := ShipandInvoice;
        this.ShipmentCountTotal := ShipmentCountTotal;
    end;

    procedure SetWhseShptHeader(var WhseShptHdr: Record "Warehouse Shipment Header")
    begin
        this.WhseShptHdr := WhseShptHdr;
    end;

    trigger OnRun()
    begin
        if not BatchPost then
            exit;
        PostShipmentYesNo(WhseShptHdr);
    end;

    local procedure PostShipmentYesNo(var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShipmentYesNo: Codeunit "Whse.-Post Shipment (Yes/No)";
    begin
        GetLinesForRec(WhseShptLine, WhseShptHeader);
        BindSubscription(this);
        WhsePostShipmentYesNo.Run(WhseShptLine);
        UnbindSubscription(this);
    end;

    local procedure GetLinesForRec(var WhseShptLine: Record "Warehouse Shipment Line"; var WhseShptHeader: Record "Warehouse Shipment Header")
    begin
        WhseShptLine.SetRange("No.", WhseShptHeader."No.");
        WhseShptLine.FindSet();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", OnBeforeConfirmWhseShipmentPost, '', true, true)]
    local procedure SetParameterOnBeforeConfirmWhseShipmentPost(var HideDialog: Boolean; var Invoice: Boolean; var IsPosted: Boolean)
    var
        UserSetupManagement: Codeunit "User Setup Management";
    begin
        if this.BatchPost then begin
            UserSetupManagement.GetSalesInvoicePostingPolicy(HideDialog, Invoice);
            HideDialog := true;
            Invoice := ShipandInvoice;
            IsPosted := false;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", OnGetResultMessageOnBeforeShowMessage, '', true, true)]
    local procedure OnGetBatchResultMessageOnBeforeShowMessage(var CounterSourceDocOK: Integer; var CounterSourceDocTotal: Integer; var IsHandled: Boolean)
    begin
        if this.ShipmentCount <> 0 then
            exit;

        if this.BatchPost then begin
            CounterSourceDocOK := (this.ShipmentCountTotal - this.ShipmentCount + 1);
            CounterSourceDocTotal := this.ShipmentCountTotal;
            IsHandled := false;
        end;
    end;

}