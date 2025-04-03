page 6185038 "NPR NpIa POSEntryLineBundlePrt"
{
    Extensible = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpIa POSEntryLineBndlAsset";
    Caption = 'Item AddOn POS Entry Sale Line Bundle Assets';
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Bundle; Rec.Bundle)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bundle Line No. field.';
                    Editable = false;
                }
                field(AssetCaption; _AssetType)
                {
                    Caption = 'Type';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Caption field.';
                    Editable = false;
                }
                field(AssetItemNumber; _AssetItemNumber)
                {
                    Caption = 'Item No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Item No. field.';
                    Editable = false;
                }
                field(ReferenceNumber; _AssetReferenceNumber)
                {
                    Caption = 'Reference No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Reference Number field.';
                    Editable = false;
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    var
        Ticket: Record "NPR TM Ticket";
        RecRef: RecordRef;
    begin
        RecRef.Open(Rec.AssetTableId);
        _AssetType := CopyStr(RecRef.Caption(), 1, MaxStrLen(_AssetType));

        case Rec.AssetTableId of

            Database::"NPR TM Ticket":
                begin
                    if Ticket.GetBySystemId(Rec.AssetSystemId) then begin
                        _AssetItemNumber := Ticket."Item No.";
                        _AssetReferenceNumber := Ticket."External Ticket No.";
                    end;
                end;
            else begin
                _AssetReferenceNumber := CopyStr(format(Rec.AssetSystemId, 0, 4).ToLower(), 1, MaxStrLen(_AssetReferenceNumber));
            end;
        end;
    end;

    var
        _AssetItemNumber: Code[20];
        _AssetReferenceNumber: Text[50];
        _AssetType: Text[250];

}