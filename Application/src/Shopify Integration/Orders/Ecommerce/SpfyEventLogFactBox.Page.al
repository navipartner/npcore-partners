#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185129 "NPR Spfy Event Log FactBox"
{
    Extensible = false;
    Caption = 'Details';
    PageType = CardPart;
    SourceTable = "NPR Spfy Event Log Entry";
    Editable = false;
    ApplicationArea = NPRShopifyEcommerce;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            usercontrol(Panel; "NPR Spfy Details Panel")
            {
                ApplicationArea = NPRShopifyEcommerce;

                trigger ControlReady()
                var
                    LabelsText: Text;
                begin
                    _SpfyEventLogDetails.BuildLabels().WriteTo(LabelsText);
                    CurrPage.Panel.SetLabels(LabelsText);
                    _ControlReady := true;
                    _PushedInGetRecord := false;
                    PushDetails();
                end;

                trigger RetryClicked()
                begin
                    RetryNow();
                end;

                trigger ShowErrorClicked()
                begin
                    if Rec."Last Error Message" <> '' then
                        Message('%1', Rec."Last Error Message");
                end;

                trigger ExternalNoClicked()
                begin
                    ShowExternalDocument();
                end;

                trigger OrderHistoryClicked()
                var
                    SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
                begin
                    SpfyEventLogMgt.ShowOrderHistory(Rec);
                end;
            }
        }
    }

    var
        _SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        _ControlReady: Boolean;
        _PushedInGetRecord: Boolean;
        _PushedEntryNo: BigInteger;

    //  Both triggers: on a row change the part re-reads the record and fires OnAfterGetRecord, but OnAfterGetCurrRecord is not reliably raised for a FactBox.
    //  When OnAfterGetCurrRecord does follow for the row just pushed, it skips the second push.
    trigger OnAfterGetRecord()
    begin
        _PushedInGetRecord := PushDetails();
        if _PushedInGetRecord then
            _PushedEntryNo := Rec."Entry No.";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if not (_PushedInGetRecord and (_PushedEntryNo = Rec."Entry No.")) then
            PushDetails();
        _PushedInGetRecord := false;
    end;

    local procedure PushDetails(): Boolean
    var
        DetailsText: Text;
    begin
        if not _ControlReady then
            exit(false);
        if Rec."Entry No." = 0 then begin
            CurrPage.Panel.Clear();
            exit(false);
        end;

        _SpfyEventLogDetails.BuildDetails(Rec).WriteTo(DetailsText);
        CurrPage.Panel.SetDetails(DetailsText);
        exit(true);
    end;

    local procedure RetryNow()
    var
        EntriesToProcess: Record "NPR Spfy Event Log Entry";
        SelectedEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        SelectedEntry.SetRange("Entry No.", Rec."Entry No.");
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntry, EntriesToProcess);
        SpfyEventLogMgt.ProcessAndReport(EntriesToProcess);

        if Rec.Get(Rec."Entry No.") then;
        CurrPage.Update(false);
        PushDetails();
    end;

    local procedure ShowExternalDocument()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        NotFoundMsg: Label 'Ecommerce document %1 was not found.', Comment = '%1 = External No.';
    begin
        if not SpfyEventLogDocProcessr.GetCreatedEcommerceDoc(Rec, EcomSalesHeader) then begin
            Message(NotFoundMsg, Rec."Shopify ID");
            exit;
        end;
        Page.Run(Page::"NPR Ecom Sales Document", EcomSalesHeader);
    end;
}
#endif
