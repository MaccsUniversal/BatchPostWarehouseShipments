
codeunit 50100 "Whse.-Batch Post Shipment"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        if not BatchPost then
            exit;
        PostShipment(WhseShptHdr);
    end;

    var
        ShipandInvoice: Boolean;
        PostingDate: Date;
        BatchPost: Boolean;
        ShipmentCount: Integer;
        TotalShipments: Integer;
        WhseShptHdr: Record "Warehouse Shipment Header";

    procedure SetParameters(BatchPost: Boolean; var ShipandInvoice: Boolean)
    begin
        this.BatchPost := BatchPost;
        this.ShipandInvoice := ShipandInvoice;
    end;

    procedure SetWhseShptHeader(var WhseShptHdr: Record "Warehouse Shipment Header")
    begin
        this.WhseShptHdr := WhseShptHdr;
    end;

    local procedure PostShipment(var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShipmentYesNo: Codeunit "Whse.-Post Shipment (Yes/No)";
    begin
        BindSubscription(this);
        WhseShptHeader.FindSet();
        TotalShipments := WhseShptHeader.Count();
        ShipmentCount := 0;
        repeat
            ShipmentCount += 1;
            GetLinesForRec(WhseShptLine, WhseShptHeader);
            WhsePostShipmentYesNo.Run(WhseShptLine);
        until WhseShptHeader.Next() <= 0;
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
            CounterSourceDocOK := this.ShipmentCount;
            CounterSourceDocTotal := this.TotalShipments;
            IsHandled := false;
        end;
    end;

}