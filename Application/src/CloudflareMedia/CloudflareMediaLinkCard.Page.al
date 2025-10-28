page 6185104 "NPR CloudflareMediaLinkCard"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR CloudflareMediaLink";
    Caption = 'Cloudflare Media Link';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(SourceTableFields)
            {

                Caption = 'Source Table Fields';
                field(PublicId; Rec.PublicId)
                {
                    ToolTip = 'Specifies the value of the Public ID field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(TableNumber; Rec.TableNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Table Number field.';
                    Editable = false;
                    Visible = false;
                }
                field("RecordId"; Rec."RecordId")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Record ID field.';
                    Editable = false;
                    Visible = false;
                }
                field(MediaSelector; Rec.MediaSelector)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Media Selector field.';
                    Editable = false;
                }
            }
            group(MediaFields)
            {
                Caption = 'Media Fields';

                field(MediaKey; Rec.MediaKey)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Media Key field.';
                    Editable = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(CloudflareImageFactBox; "NPR CloudflareImageFactBox")
            {
                ApplicationArea = NPRRetail;
                SubPageLink = TableNumber = FIELD(TableNumber),
                              RecordId = FIELD(RecordId),
                              MediaSelector = FIELD(MediaSelector);
                Visible = true;
            }
        }
    }
}