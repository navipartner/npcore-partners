page 6184713 "NPR Store Shipment Profiles"
{
    Caption = 'Store Shipment Profiles';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR Store Ship. Profile Header";
    Editable = false;
    Extensible = false;
    CardPageId = "NPR Store Ship. Profile Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}