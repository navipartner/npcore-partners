page 6014526 "NPR APIV1 - Variety Group"
{

    APIGroup = 'variety';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'VarietyGroup';
    DelayedInsert = true;
    EntityName = 'varietyGroup';
    EntitySetName = 'varietyGroups';
    Extensible = false;
    PageType = API;
    ODataKeyFields = SystemId;
    SourceTable = "NPR Variety Group";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(crossVarietyNo; Rec."Cross Variety No.")
                {
                    Caption = 'crossVarietyNo', Locked = true;
                }
                field(variety1; Rec."Variety 1")
                {
                    Caption = 'variety1', Locked = true;
                }
                field(variety1Table; Rec."Variety 1 Table")
                {
                    Caption = 'variety1Table', Locked = true;
                }
                field(createCopyofVariety1Table; Rec."Create Copy of Variety 1 Table")
                {
                    Caption = 'createCopyofVariety1Table', Locked = true;
                }
                field(copyNamingVariety1; Rec."Copy Naming Variety 1")
                {
                    Caption = 'copyNamingVariety1', Locked = true;
                }
                field(variety2; Rec."Variety 2")
                {
                    Caption = 'variety2', Locked = true;
                }
                field(variety2Table; Rec."Variety 2 Table")
                {
                    Caption = 'variety2Table', Locked = true;
                }
                field(createCopyofVariety2Table; Rec."Create Copy of Variety 2 Table")
                {
                    Caption = 'createCopyofVariety2Table', Locked = true;
                }
                field(copyNamingVariety2; Rec."Copy Naming Variety 2")
                {
                    Caption = 'copyNamingVariety2', Locked = true;
                }
                field(variety3; Rec."Variety 3")
                {
                    Caption = 'variety3', Locked = true;
                }
                field(variety3Table; Rec."Variety 3 Table")
                {
                    Caption = 'variety3Table', Locked = true;
                }
                field(createCopyofVariety3Table; Rec."Create Copy of Variety 3 Table")
                {
                    Caption = 'createCopyofVariety3Table', Locked = true;
                }
                field(copyNamingVariety3; Rec."Copy Naming Variety 3")
                {
                    Caption = 'copyNamingVariety3', Locked = true;
                }
                field(variety4; Rec."Variety 4")
                {
                    Caption = 'variety4', Locked = true;
                }
                field(variety4Table; Rec."Variety 4 Table")
                {
                    Caption = 'variety4Table', Locked = true;
                }
                field(createCopyofVariety4Table; Rec."Create Copy of Variety 4 Table")
                {
                    Caption = 'createCopyofVariety4Table', Locked = true;
                }
                field(copyNamingVariety4; Rec."Copy Naming Variety 4")
                {
                    Caption = 'copyNamingVariety4', Locked = true;
                }
                field(variantCodePart1; Rec."Variant Code Part 1")
                {
                    Caption = 'variantCodePart1', Locked = true;
                }
                field(variantCodeSeperator1; Rec."Variant Code Seperator 1")
                {
                    Caption = 'variantCodeSeperator1', Locked = true;
                }
                field(variantCodePart2; Rec."Variant Code Part 2")
                {
                    Caption = 'variantCodePart2', Locked = true;
                }
                field(variantCodePart1Length; Rec."Variant Code Part 1 Length")
                {
                    Caption = 'variantCodePart1Length', Locked = true;
                }
                field(variantCodePart2Length; Rec."Variant Code Part 2 Length")
                {
                    Caption = 'variantCodePart2Length', Locked = true;
                }
                field(variantCodeSeperator2; Rec."Variant Code Seperator 2")
                {
                    Caption = 'variantCodeSeperator2', Locked = true;
                }
                field(variantCodePart3; Rec."Variant Code Part 3")
                {
                    Caption = 'variantCodePart3', Locked = true;
                }
                field(variantCodePart3Length; Rec."Variant Code Part 3 Length")
                {
                    Caption = 'variantCodePart3Length', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }

                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
