page 6150673 "NPR POS Audit Log"
{
    // NPR5.48/MMV /20180605 CASE 318028 Created object
    // NPR5.51/MMV /20190619 CASE 356076 Added missing action icon

    Caption = 'POS Audit Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Audit Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field(FormattedRecordID; FormattedRecordID)
                {
                    ApplicationArea = All;
                    Caption = 'Record ID';
                    ToolTip = 'Specifies the value of the Record ID field';
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Action Custom Subtype"; "Action Custom Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Custom Subtype field';
                }
                field("Acted on POS Entry No."; "Acted on POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acted on POS Entry No. field';
                }
                field("Acted on POS Entry Fiscal No."; "Acted on POS Entry Fiscal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acted on POS Entry Fiscal No. field';
                }
                field("Active POS Unit No."; "Active POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active POS Unit No. field';
                }
                field("Active Salesperson Code"; "Active Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active Salesperson Code field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Log Timestamp"; "Log Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Timestamp field';
                }
                field("External Type"; "External Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Type field';
                }
                field("External ID"; "External ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External ID field';
                }
                field("External Code"; "External Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Code field';
                }
                field("External Description"; "External Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Description field';
                }
                field("Additional Information"; "Additional Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Additional Information field';
                }
                field(BaseValue; BaseValue)
                {
                    ApplicationArea = All;
                    Caption = 'Signature Base Value';
                    ToolTip = 'Specifies the value of the Signature Base Value field';
                }
                field("Signature Base Hash"; "Signature Base Hash")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Signature Base Hash field';
                }
                field(Signature; Signature)
                {
                    ApplicationArea = All;
                    Caption = 'Signature';
                    ToolTip = 'Specifies the value of the Signature field';
                }
                field(PreviousSignature; PreviousSignature)
                {
                    ApplicationArea = All;
                    Caption = 'Previous Signature';
                    ToolTip = 'Specifies the value of the Previous Signature field';
                }
                field("Certificate Thumbprint"; "Certificate Thumbprint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Certificate Thumbprint field';
                }
                field("Certificate Implementation"; "Certificate Implementation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Certificate Implementation field';
                }
                field("External Implementation"; "External Implementation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Implementation field';
                }
                field("Handled by External Impl."; "Handled by External Impl.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled by External Impl. field';
                }
                field("Active POS Sale ID"; "Active POS Sale ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active POS Sale ID field';
                }
                field("Acted on POS Unit No."; "Acted on POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acted on POS Unit No. field';
                }
                field(Uploaded; Uploaded)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Uploaded field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Validate Log action';

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    POSAuditLog: Record "NPR POS Audit Log";
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

