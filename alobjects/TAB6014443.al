table 6014443 "Touch Screen - MetaTriggers"
{
    // NPR/RMT/20150210 Case 198862 - code on "Var Record Param" - OnLookup to locate valid values
    // NPR5.22/BHR/20160404 CASE 236679 Changed the Table Caption from 'Usage -retail' to 'Touch Screen - MetaTriggers'
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 4

    Caption = 'Touch Screen - MetaTriggers';

    fields
    {
        field(1;"On function call";Code[50])
        {
            Caption = 'On function call';
            TableRelation = "Touch Screen - Meta Functions".Code;
        }
        field(2;Sequence;Integer)
        {
            Caption = 'Sequence';
        }
        field(3;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = Register;
        }
        field(4;ID;Integer)
        {
            Caption = 'ID';
            TableRelation = IF ("Line Type"=CONST(Codeunit)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Line Type"=CONST(Page)) AllObj."Object ID" WHERE ("Object Type"=CONST(Page))
                            ELSE IF ("Line Type"=CONST(Report)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(5;"Line Type";Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Report,Form,Internal,Codeunit,Page';
            OptionMembers = "Report",Form,Internal,"Codeunit","Page";
        }
        field(6;"Var Parameter";Option)
        {
            Caption = 'Var Parameter';
            OptionCaption = ' ,Sale,Sales Line';
            OptionMembers = " ",Sale,SalesLine;
        }
        field(7;"Var Record Param";Text[250])
        {
            Caption = 'Var Record Param';

            trigger OnLookup()
            var
                AllObj: Record AllObj;
                MetaTriggerMgt: Codeunit "Meta Trigger Management";
                AllObjects: Page "All Objects";
            begin
                //-CASE198862
                case "Line Type" of
                  "Line Type"::Report:
                    begin
                      AllObj.SetRange("Object Type",AllObj."Object Type"::Report);
                      AllObjects.LookupMode(true);
                      AllObjects.Editable(false);
                      AllObjects.SetTableView(AllObj);
                      if AllObjects.RunModal=ACTION::LookupOK then begin
                        AllObjects.GetRecord(AllObj);
                        Validate("Var Record Param",Format(AllObj."Object ID"));
                      end;
                    end;
                  "Line Type"::Form:
                    begin
                    end;
                  "Line Type"::Internal:
                    begin
                      Validate("Var Record Param",MetaTriggerMgt.DoLookup("Var Record Param"));
                    end;
                  "Line Type"::Codeunit:
                    begin
                      AllObj.SetRange("Object Type",AllObj."Object Type"::Codeunit);
                      AllObjects.LookupMode(true);
                      AllObjects.Editable(false);
                      AllObjects.SetTableView(AllObj);
                      if AllObjects.RunModal=ACTION::LookupOK then begin
                        AllObjects.GetRecord(AllObj);
                        Validate("Var Record Param",Format(AllObj."Object ID"));
                      end;
                    end;
                  "Line Type"::Page:
                    begin
                      AllObj.SetRange("Object Type",AllObj."Object Type"::Page);
                      AllObjects.LookupMode(true);
                      AllObjects.Editable(false);
                      AllObjects.SetTableView(AllObj);
                      if AllObjects.RunModal=ACTION::LookupOK then begin
                        AllObjects.GetRecord(AllObj);
                        Validate("Var Record Param",Format(AllObj."Object ID"));
                      end;
                    end;
                end;
                //+CASE198862
            end;
        }
        field(8;When;Option)
        {
            Caption = 'When';
            OptionCaption = 'Before,After';
            OptionMembers = Before,After;
        }
    }

    keys
    {
        key(Key1;"On function call",Sequence)
        {
        }
        key(Key2;When,Sequence,"Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RapportValg2: Record "Report Selection Retail";
        printerID: Record "Period Line";
}

