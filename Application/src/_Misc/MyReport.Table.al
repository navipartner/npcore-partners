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
            DataClassification = CustomerContent;
        }
        field(2; "Report No."; Integer)
        {
            Caption = 'Report No.';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User ID", "Report No.")
        {
        }
    }
    local procedure AddEntities(FilterStr: Text[250])
    var
        AllObj: Record AllObj;
        "Report": Record "Object";
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Report);
        AllObj.SetFilter("Object ID", FilterStr);
        if AllObj.FindSet() then
            repeat
                "User ID" := UserId;
                "Report No." := AllObj."Object ID";
                if not Insert() then;
            until AllObj.Next() = 0;
    end;
}

