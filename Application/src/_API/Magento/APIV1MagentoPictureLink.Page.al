page 6060014 "NPR APIV1 - MagentoPictureLink"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoPictureLink';
    EntitySetName = 'magentoPictureLinks';
    EntityCaption = 'Magento Picture Link';
    EntitySetCaption = 'Magento Picture Links';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Picture Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(path; Rec.Path)
                {
                    Caption = 'Path', Locked = true;
                }
                field(shortText; Rec."Short Text")
                {
                    Caption = 'Short Text', Locked = true;
                }
                field(variantValueCode; Rec."Variant Value Code")
                {
                    Caption = 'Variant Value Code', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR26.0';
                    ObsoleteReason = 'We are going to use field 60 "Variety Value" from the same table.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(baseImage; Rec."Base Image")
                {
                    Caption = 'Base Image', Locked = true;
                }
                field(smallImage; Rec."Small Image")
                {
                    Caption = 'Small Image', Locked = true;
                }
                field(thumbnail; Rec.Thumbnail)
                {
                    Caption = 'Thumbnail', Locked = true;
                }
                field("sorting"; Rec.Sorting)
                {
                    Caption = 'Sorting', Locked = true;
                }
                field(varietyType; Rec."Variety Type")
                {
                    Caption = 'Variety Type', Locked = true;
                }
                field(varietyTable; Rec."Variety Table")
                {
                    Caption = 'Variety Table', Locked = true;
                }
                field(varietyValue; Rec."Variety Value")
                {
                    Caption = 'Variety Value', Locked = true;
                }
                field(pictureName; Rec."Picture Name")
                {
                    Caption = 'Picture Name', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
