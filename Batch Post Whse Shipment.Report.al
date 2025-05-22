report 50100 "Batch Post Warehouse Shpt Doc."
{
    ApplicationArea = Basic, Suite;
    Caption = 'Batch Post Warehouse Shipment Document';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            DataItemTableView = sorting("No.") order(descending);
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Warehouse Shipment Doc.';
        }

    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(ShipReq; Ship)
                    {
                        Caption = 'Ship';
                        Tooltip = 'Select when you want to Ship the document. The Sales Order will NOT be invoiced.';

                        trigger OnValidate()
                        begin
                            if not Ship then
                                ShipandInvoice := true
                            else
                                ShipandInvoice := false;
                        end;
                    }

                    field(InvoiceReq; ShipandInvoice)
                    {
                        Caption = 'Ship & Invoice';
                        ToolTip = 'Select to invoice the Sales Order after Warehouse Shipment Document has been shipped. Leave this off for just a shipment of the Warehouse Shipment Document.';

                        trigger OnValidate()
                        begin
                            if not ShipandInvoice then
                                Ship := true
                            else
                                Ship := false;
                        end;
                    }

                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date';
                        Tooltip = 'Specifies a posting date. If you enter a date, the posting date of the selected shipments are updated during posting.';

                    }


                }
            }

        }

        actions
        {
        }

    }

    trigger OnPreReport()
    begin
        CheckAllowedPostingDate(PostingDate);
    end;

    trigger OnPostReport()
    var
        WhseBatchPostShipment: Codeunit "Whse.-Batch Post Shipment";
    begin
        if not ConfirmPostingDate(PostingDate) then
            exit;

        FindWhseShptHeaderSet();
        WhseBatchPostShipment.SetParameters(true, ShipandInvoice, PostingDate);
        WhseBatchPostShipment.SetWhseShptHeader("Warehouse Shipment Header");
        WhseBatchPostShipment.Run();
    end;

    local procedure FindWhseShptHeaderSet()
    var
        IsHandled: Boolean;
    begin
        OnBeforeFindWarehouseShipmentHeaderSet("Warehouse Shipment Header", IsHandled);
        if IsHandled then
            exit;

        "Warehouse Shipment Header".FindSet();

        OnAfterFindWarehouseShipmentHeaderSet("Warehouse Shipment Header");
    end;

    local procedure ConfirmPostingDate(var PostingDate: Date): Boolean
    var
        HideDialog: Boolean;
        DefaultOption: Boolean;
        Result: Boolean;
        Answer: Boolean;
    begin
        HideDialog := false;
        DefaultOption := false;
        Result := true;
        OnBeforeConfirmPostingDate(HideDialog, PostingDate, DefaultOption, Result);

        if HideDialog then
            exit(Result);

        Answer := Confirm(Text000, DefaultOption, PostingDate);
        if not Answer then
            exit(false);

        OnAfterConfirmPostingDate(PostingDate);

        exit(Result)
    end;

    local procedure CheckAllowedPostingDate(var PostingDate: Date): Boolean
    var
        UserSetupManagement: Codeunit "User Setup Management";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckAllowedPostingDate(PostingDate, IsHandled, Result);

        if IsHandled then
            exit(Result);

        UserSetupmanagement.CheckAllowedPostingDate(PostingDate);

        OnAfterCheckAllowedPostingDate(PostingDate);
    end;

    protected var
        Ship: Boolean;
        ShipandInvoice: Boolean;
        PostingDate: Date;
        Text000: Label 'All Posting Dates will be Replaced the date %1. Are you sure you want to Post Shipments and Invoices to the Posting Date %1?';


    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPostingDate(var PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckAllowedPostingDate(var PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindWarehouseShipmentHeaderSet(var WhseShptHeader: Record "Warehouse Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAllowedPostingDate(var PostingDate: Date; var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindWarehouseShipmentHeaderSet(var WhseShptHeader: Record "Warehouse Shipment Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPostingDate(var HideDialog: Boolean; var PostingDate: Date; var DefaultOption: Boolean; var Result: Boolean)
    begin
    end;


}

