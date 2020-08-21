page 6150673 "POS Audit Log"
{
    // NPR5.48/MMV /20180605 CASE 318028 Created object
    // NPR5.51/MMV /20190619 CASE 356076 Added missing action icon

    Caption = 'POS Audit Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "POS Audit Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(FormattedRecordID; FormattedRecordID)
                {
                    ApplicationArea = All;
                    Caption = 'Record ID';
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                }
                field("Action Custom Subtype"; "Action Custom Subtype")
                {
                    ApplicationArea = All;
                }
                field("Acted on POS Entry No."; "Acted on POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Acted on POS Entry Fiscal No."; "Acted on POS Entry Fiscal No.")
                {
                    ApplicationArea = All;
                }
                field("Active POS Unit No."; "Active POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Active Salesperson Code"; "Active Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Log Timestamp"; "Log Timestamp")
                {
                    ApplicationArea = All;
                }
                field("External Type"; "External Type")
                {
                    ApplicationArea = All;
                }
                field("External ID"; "External ID")
                {
                    ApplicationArea = All;
                }
                field("External Code"; "External Code")
                {
                    ApplicationArea = All;
                }
                field("External Description"; "External Description")
                {
                    ApplicationArea = All;
                }
                field("Additional Information"; "Additional Information")
                {
                    ApplicationArea = All;
                }
                field(BaseValue; BaseValue)
                {
                    ApplicationArea = All;
                    Caption = 'Signature Base Value';
                }
                field("Signature Base Hash"; "Signature Base Hash")
                {
                    ApplicationArea = All;
                }
                field(Signature; Signature)
                {
                    ApplicationArea = All;
                    Caption = 'Signature';
                }
                field(PreviousSignature; PreviousSignature)
                {
                    ApplicationArea = All;
                    Caption = 'Previous Signature';
                }
                field("Certificate Thumbprint"; "Certificate Thumbprint")
                {
                    ApplicationArea = All;
                }
                field("Certificate Implementation"; "Certificate Implementation")
                {
                    ApplicationArea = All;
                }
                field("External Implementation"; "External Implementation")
                {
                    ApplicationArea = All;
                }
                field("Handled by External Impl."; "Handled by External Impl.")
                {
                    ApplicationArea = All;
                }
                field("Active POS Sale ID"; "Active POS Sale ID")
                {
                    ApplicationArea = All;
                }
                field("Acted on POS Unit No."; "Acted on POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field(Uploaded; Uploaded)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ValidateLog)
            {
                Caption = 'Validate Log';
                Image = Approval;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
                    POSAuditLog: Record "POS Audit Log";
                begin
                    POSAuditLog.SetView(Rec.GetView());
                    POSAuditLogMgt.ValidateLog(POSAuditLog);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        InStream: InStream;
    begin
        Clear(Signature);
        Clear(PreviousSignature);
        Clear(BaseValue);

        CalcFields("Electronic Signature", "Previous Electronic Signature", "Signature Base Value");

        if "Electronic Signature".HasValue then begin
            "Electronic Signature".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(Signature);
            end;
            Clear(InStream);
        end;

        if "Previous Electronic Signature".HasValue then begin
            "Previous Electronic Signature".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(PreviousSignature);
            end;
            Clear(InStream);
        end;

        if "Signature Base Value".HasValue then begin
            "Signature Base Value".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(BaseValue);
            end;
            Clear(InStream);
        end;

        FormattedRecordID := Format("Record ID");
    end;

    var
        FormattedRecordID: Text;
        Signature: Text;
        PreviousSignature: Text;
        BaseValue: Text;
}

