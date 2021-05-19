page 6150673 "NPR POS Audit Log"
{
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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Table Name"; Rec."Table Name")
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
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Action Custom Subtype"; Rec."Action Custom Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Custom Subtype field';
                }
                field("Acted on POS Entry No."; Rec."Acted on POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acted on POS Entry No. field';
                }
                field("Acted on POS Entry Fiscal No."; Rec."Acted on POS Entry Fiscal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acted on POS Entry Fiscal No. field';
                }
                field("Active POS Unit No."; Rec."Active POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active POS Unit No. field';
                }
                field("Active Salesperson Code"; Rec."Active Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active Salesperson Code field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Log Timestamp"; Rec."Log Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Timestamp field';
                }
                field("External Type"; Rec."External Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Type field';
                }
                field("External ID"; Rec."External ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External ID field';
                }
                field("External Code"; Rec."External Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Code field';
                }
                field("External Description"; Rec."External Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Description field';
                }
                field("Additional Information"; Rec."Additional Information")
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
                field("Signature Base Hash"; Rec."Signature Base Hash")
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
                field("Certificate Thumbprint"; Rec."Certificate Thumbprint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Certificate Thumbprint field';
                }
                field("Certificate Implementation"; Rec."Certificate Implementation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Certificate Implementation field';
                }
                field("External Implementation"; Rec."External Implementation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Implementation field';
                }
                field("Handled by External Impl."; Rec."Handled by External Impl.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled by External Impl. field';
                }
                field("Acted on POS Unit No."; Rec."Acted on POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acted on POS Unit No. field';
                }
                field(Uploaded; Rec.Uploaded)
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

        Rec.CalcFields("Electronic Signature", "Previous Electronic Signature", "Signature Base Value");

        if Rec."Electronic Signature".HasValue() then begin
            Rec."Electronic Signature".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(Signature);
            end;
            Clear(InStream);
        end;

        if Rec."Previous Electronic Signature".HasValue() then begin
            Rec."Previous Electronic Signature".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(PreviousSignature);
            end;
            Clear(InStream);
        end;

        if Rec."Signature Base Value".HasValue() then begin
            Rec."Signature Base Value".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(BaseValue);
            end;
            Clear(InStream);
        end;

        FormattedRecordID := Format(Rec."Record ID");
    end;

    var
        FormattedRecordID: Text;
        Signature: Text;
        PreviousSignature: Text;
        BaseValue: Text;
}