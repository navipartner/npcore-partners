tableextension 50052 tableextension50052 extends "User Setup" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                       Added fields 6014400
    // NPR5.20/VB  /20160226  CASE 235620 Added field 6014627
    // NPR5.26/MMV /20160905  CASE 242977 Removed field 6014627.
    // NPR5.27/BHR /20160930  CASE 253589 Add lookup to field 'Use register'
    // NPR5.38/MHA /20180115  CASE 302240 Added fields 6014405 "Allow Register Switch" and 6014410 "Register Switch Filter"
    // NPR5.46/MMV /20181003  CASE 290734 Renamed field 6014400 to make its purpose clear when used with transcendence.
    fields
    {
        field(6014400;"Backoffice Register No.";Code[10])
        {
            Caption = 'Backoffice Register No.';
            Description = 'NPR7.100.000';
            TableRelation = Register;
        }
        field(6014405;"Allow Register Switch";Boolean)
        {
            Caption = 'Allow Register Switch';
            Description = 'NPR5.38';
            TableRelation = Register;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6014410;"Register Switch Filter";Text[100])
        {
            Caption = 'Register Switch Filter';
            Description = 'NPR5.38';
        }
        field(6014599;"Connection Profile Code";Code[20])
        {
            Caption = 'Connection Profile Code';
            TableRelation = "Connection Profile";
        }
    }
}

