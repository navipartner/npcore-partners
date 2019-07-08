table 6059966 "MPOS App Setup"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/MMV /20170926 CASE 291652 Added quickfix field 1000
    // NPR5.36/NPKNAV/20171003  CASE 280444-01 Transport NPR5.36 - 3 October 2017
    // NPR5.38/CLVA/20171011 CASE 289636 Added fields "Receipt Report ID" and "Receipt Report Caption"
    // NPR5.39/BR  /20180214 CASE 304312 Renamed field "Receipt Report ID" and "Receipt Report Caption" to "Audit Roll Report ID" and "Audit Roll Report Caption", and added fields "POS Entry Report ID" and "POS Entry Report Caption"
    // NPR5.39/JDH /20180220 CASE 305746 Audit Roll Report Caption + POS Entry Report Caption changed to 249 characters

    Caption = 'MPOS App Setup';

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = Register;
        }
        field(11;"Payment Gateway";Code[10])
        {
            Caption = 'Payment Gateway';
            TableRelation = "MPOS Payment Gateway";
        }
        field(12;"Web Service Is Published";Boolean)
        {
            CalcFormula = Exist("Web Service" WHERE ("Object Type"=CONST(Codeunit),
                                                     "Service Name"=CONST('mpos_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13;"Ticket Admission Web Url";Text[250])
        {
            Caption = 'Ticket Admission Web Url';
        }
        field(14;"Audit Roll Report ID";Integer)
        {
            Caption = 'Audit Roll Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Audit Roll Report Caption");
            end;
        }
        field(15;"Audit Roll Report Caption";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Audit Roll Report ID")));
            Caption = 'Audit Roll Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16;"Receipt Web API";Text[250])
        {
            Caption = 'Receipt Web API';
        }
        field(17;"Custom Web Service URL";Text[250])
        {
            Caption = 'Custom Web Service URL';
        }
        field(18;"Receipt Source Type";Option)
        {
            Caption = 'Receipt Source Type';
            OptionCaption = 'NAV,Magento';
            OptionMembers = NAV,Magento;
        }
        field(19;"Encryption Key";Text[30])
        {
            Caption = 'Encryption Key';
            ExtendedDatatype = Masked;
        }
        field(20;"POS Entry Report ID";Integer)
        {
            Caption = 'POS Entry Report ID';
            Description = 'NPR5.39';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report));

            trigger OnValidate()
            begin
                //-NPR5.39 [304312]
                CalcFields("Audit Roll Report Caption");
                //+NPR5.39 [304312]
            end;
        }
        field(21;"POS Entry Report Caption";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("POS Entry Report ID")));
            Caption = 'POS Entry Report Caption';
            Description = 'NPR5.39';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;Enable;Boolean)
        {
            Caption = 'Enable';
        }
        field(1000;"Handle EFT Print in NAV";Boolean)
        {
            Caption = 'Handle EFT Print in NAV';
            Description = 'NPR5.36';
        }
    }

    keys
    {
        key(Key1;"Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure IsMPOSEnabled(RegisterId: Code[10]): Boolean
    var
        MPOSAppSetup: Record "MPOS App Setup";
    begin
        if MPOSAppSetup.Get(RegisterId) then
          exit(MPOSAppSetup.Enable);
    end;
}

