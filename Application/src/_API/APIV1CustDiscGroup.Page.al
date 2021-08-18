page 6014649 "NPR APIV1 - Cust Disc. Group"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1CustomerDiscGroup';
    DelayedInsert = true;
    EntityName = 'custDiscountGroup';
    EntitySetName = 'custDiscountGroups';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Customer Discount Group";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified DateTime';
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

}
