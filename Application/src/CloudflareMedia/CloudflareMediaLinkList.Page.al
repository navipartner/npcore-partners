page 6185103 "NPR CloudflareMediaLinkList"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR CloudflareMediaLink";
    Caption = 'Cloudflare Media Links';
    CardPageId = "NPR CloudflareMediaLinkCard";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(PublicId; Rec.PublicId)
                {
                    ToolTip = 'Specifies the value of the Public ID field.';
                    ApplicationArea = NPRRetail;
                }
                field(TableNumber; Rec.TableNumber)
                {
                    ToolTip = 'Specifies the value of the Table Number field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("RecordId"; Rec."RecordId")
                {
                    ToolTip = 'Specifies the value of the Record ID field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(MediaSelector; Rec.MediaSelector)
                {
                    ToolTip = 'Specifies the value of the Media Selector field.';
                    ApplicationArea = NPRRetail;
                }

                field(MediaKey; Rec.MediaKey)
                {
                    ToolTip = 'Specifies the value of the Media Key field.';
                    ApplicationArea = NPRRetail;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRRetail;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}