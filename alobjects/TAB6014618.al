table 6014618 "My Report"
{
    // #6014618/JC/20160110  CASE 258075 Created Object My Report
    // NPR5.29/NPKNAV/20170127  CASE 258075 Transport NPR5.29 - 27 januar 2017
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Caption = 'My Item';

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2;"Report No.";Integer)
        {
            Caption = 'Report No.';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
    }

    keys
    {
        key(Key1;"User ID","Report No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure AddEntities(FilterStr: Text[250])
    var
        "Report": Record "Object";
        AllObj: Record AllObj;
    begin
        //-NPR5.46 [322752]
        // Report.SETRANGE(Type, Report.Type::Report);
        // Report.SETFILTER(ID,FilterStr);
        // IF Report.FINDSET THEN
        //  REPEAT
        //    "User ID" := USERID;
        //    "Report No." := Report.ID;
        //    IF NOT INSERT THEN;
        //  UNTIL Report.NEXT = 0;

        AllObj.SetRange("Object Type", AllObj."Object Type"::Report);
        AllObj.SetFilter("Object ID",FilterStr);
        if AllObj.FindSet then
          repeat
            "User ID" := UserId;
            "Report No." := AllObj."Object ID";
            if not Insert then;
          until AllObj.Next = 0;
        //+NPR5.46 [322752]
    end;
}

