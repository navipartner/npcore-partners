page 6060036 "NPR APIV1 PBIItem Variant"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemVariant';
    EntitySetName = 'itemVariants';
    Caption = 'PowerBI Item Variant';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Variant";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec."Description")
                {
                    Caption = 'Description', Locked = true;
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2', Locked = true;
                }
                field(itemId; Rec."Item Id")
                {
                    Caption = 'Item Id', Locked = true;
                }
                field(nprVariety1; Rec."NPR Variety 1")
                {
                    Caption = 'NPR Variety 1', Locked = true;
                }
                field(nprVariety1Table; Rec."NPR Variety 1 Table")
                {
                    Caption = 'NPR Variety 1 Table', Locked = true;
                }
                field(nprVariety1Value; Rec."NPR Variety 1 Value")
                {
                    Caption = 'NPR Variety 1 Value', Locked = true;
                }
                field(nprVariety2; Rec."NPR Variety 2")
                {
                    Caption = 'NPR Variety 2', Locked = true;
                }
                field(nprVariety2Table; Rec."NPR Variety 2 Table")
                {
                    Caption = 'NPR Variety 2 Table', Locked = true;
                }
                field(nprVariety2Value; Rec."NPR Variety 2 Value")
                {
                    Caption = 'NPR Variety 2 Value', Locked = true;
                }
                field(nprVariety3; Rec."NPR Variety 3")
                {
                    Caption = 'NPR Variety 3', Locked = true;
                }
                field(nprVariety3Table; Rec."NPR Variety 3 Table")
                {
                    Caption = 'NPR Variety 3 Table', Locked = true;
                }
                field(nprVariety3Value; Rec."NPR Variety 3 Value")
                {
                    Caption = 'NPR Variety 3 Value', Locked = true;
                }
                field(nprVariety4; Rec."NPR Variety 4")
                {
                    Caption = 'NPR Variety 4', Locked = true;
                }
                field(nprVariety4Table; Rec."NPR Variety 4 Table")
                {
                    Caption = 'NPR Variety 4 Table', Locked = true;
                }
                field(nprVariety4Value; Rec."NPR Variety 4 Value")
                {
                    Caption = 'NPR Variety 4 Value', Locked = true;
                }
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                field(nprBlocked; Rec."NPR Blocked")
                {
                    Caption = 'NPR Blocked', Locked = true;
                }
#ELSE
                field(nprBlocked; Rec.Blocked)
                {
                    Caption = 'NPR Blocked', Locked = true;
                }
#ENDIF
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}