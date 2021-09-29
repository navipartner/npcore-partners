table 6014618 "NPR My Report"
{
    Caption = 'My Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Report No."; Integer)
        {
            Caption = 'Report No.';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User ID", "Report No.")
        {
        }
    }
}