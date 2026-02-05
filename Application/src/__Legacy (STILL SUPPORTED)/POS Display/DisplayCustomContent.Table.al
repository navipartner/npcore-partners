table 6059953 "NPR Display Custom Content"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    // NPR5.50/CLVA/20190513 CASE 352390 Object created

    Caption = 'Display Custom Content';
    DataClassification = CustomerContent;

    fields
    {
        field(1; RecId; RecordID)
        {
            Caption = 'Record Id';
            DataClassification = CustomerContent;
        }
        field(2; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity';
            OptionMembers = Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        }
        field(3; NewQuantity; Decimal)
        {
            Caption = 'New Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; RecId)
        {
        }
    }

    fieldgroups
    {
    }
}

