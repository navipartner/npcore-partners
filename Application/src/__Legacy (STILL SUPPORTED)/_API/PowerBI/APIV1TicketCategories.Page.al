page 6150835 "NPR APIV1 Ticket Categories"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'ticketcategory';
    EntitySetName = 'ticketcategory';
    Caption = 'Ticket Categories';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Category";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(categoryCode; Rec.CategoryCode)
                {
                    Caption = 'Category Code';
                }
                field(categoryName; Rec.CategoryName)
                {
                    Caption = 'Category Name';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
            }
        }
    }
}
