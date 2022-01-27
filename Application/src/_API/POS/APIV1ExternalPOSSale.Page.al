page 6059775 "NPR APIV1 - External POS Sale"
{
    Extensible = False;

    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'External POS Sale';
    DelayedInsert = true;
    EntityName = 'externalPosSale';
    EntitySetName = 'externalPosSales';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR External POS Sale";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    Editable = false;
                }
                field(startTime; Rec."Start Time")
                {
                    Caption = 'Start Time';
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date';
                }
                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.';
                }

                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code';
                }

                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }

                field(pricesIncludingVAT; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT';
                }
                field(eventNo; Rec."Event No.")
                {
                    Caption = 'Event No.';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(reference; Rec.Reference)
                {
                    Caption = 'Reference';
                }
                field(convertedToPOSEntry; Rec."Converted To POS Entry")
                {
                    Caption = 'Converted To POS Entry';
                }
                field(posEntrySystemId; Rec."POS Entry System Id")
                {
                    Caption = 'POS Entry System Id';
                }

                part(externalPosSaleLines; "NPR APIV1 - Ext. POS Sale Line")
                {
                    Caption = 'External Pos Sale Lines';
                    EntityName = 'externalPosSaleLine';
                    EntitySetName = 'externalPosSaleLines';
                    SubPageLink = "External POS Sale Entry No." = field("Entry No.");
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        POSSaleCU: Codeunit "NPR POS Sale";
    begin
        IF Rec."Salesperson Code" = '' then begin
            GetUserSetup();
            Rec."Salesperson Code" := UserSetup."Salespers./Purch. Code";
        end;
        Rec.TestField("Salesperson Code");

        IF Rec.Date = 0D then
            Rec.Date := System.Today();

        IF Rec."Start Time" = 0T then
            Rec."Start Time" := System.Time();

        IF Rec."Register No." = '' then begin
            GetUserSetup();
            Rec."Register No." := UserSetup."NPR POS Unit No.";
        end;
        Rec.TestField("Register No.");

        IF Rec."Sales Ticket No." = '' then
            Rec."Sales Ticket No." := POSSaleCU.GetNextReceiptNo(Rec."Register No.");
    end;

    local procedure GetUserSetup()
    begin
        IF UserSetupRetrieved then
            exit;

        UserSetup.Get(UserId);
        UserSetupRetrieved := true;
    end;

    var
        UserSetup: Record "User Setup";
        UserSetupRetrieved: Boolean;

}
