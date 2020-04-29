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
                field("Entry No.";"Entry No.")
                {
                }
                field("Table Name";"Table Name")
                {
                }
                field(FormattedRecordID;FormattedRecordID)
                {
                    Caption = 'Record ID';
                }
                field("Action Type";"Action Type")
                {
                }
                field("Action Custom Subtype";"Action Custom Subtype")
                {
                }
                field("Acted on POS Entry No.";"Acted on POS Entry No.")
                {
                }
                field("Acted on POS Entry Fiscal No.";"Acted on POS Entry Fiscal No.")
                {
                }
                field("Active POS Unit No.";"Active POS Unit No.")
                {
                }
                field("Active Salesperson Code";"Active Salesperson Code")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Log Timestamp";"Log Timestamp")
                {
                }
                field("External Type";"External Type")
                {
                }
                field("External ID";"External ID")
                {
                }
                field("External Code";"External Code")
                {
                }
                field("External Description";"External Description")
                {
                }
                field("Additional Information";"Additional Information")
                {
                }
                field(BaseValue;BaseValue)
                {
                    Caption = 'Signature Base Value';
                }
                field("Signature Base Hash";"Signature Base Hash")
                {
                }
                field(Signature;Signature)
                {
                    Caption = 'Signature';
                }
                field(PreviousSignature;PreviousSignature)
                {
                    Caption = 'Previous Signature';
                }
                field("Certificate Thumbprint";"Certificate Thumbprint")
                {
                }
                field("Certificate Implementation";"Certificate Implementation")
                {
                }
                field("External Implementation";"External Implementation")
                {
                }
                field("Handled by External Impl.";"Handled by External Impl.")
                {
                }
                field("Active POS Sale ID";"Active POS Sale ID")
                {
                }
                field("Acted on POS Unit No.";"Acted on POS Unit No.")
                {
                }
                field(Uploaded;Uploaded)
                {
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

