table 6060018 "GIM - Document Type Version"
{
    Caption = 'GIM - Document Type Version';
    LookupPageID = "GIM - Document Types";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(3;"Version No.";Integer)
        {
            Caption = 'Version No.';
        }
        field(10;Base;Boolean)
        {
            Caption = 'Base';

            trigger OnValidate()
            begin
                if Base <> xRec.Base then begin
                  DocTypeVersion.SetRange(Code,Code);
                  DocTypeVersion.SetRange("Sender ID","Sender ID");
                  DocTypeVersion.SetRange(Base,true);
                  if Base then begin
                    if DocTypeVersion.FindFirst then begin
                      if not Confirm(Text001) then
                        Error('');
                      DocTypeVersion.Base := false;
                      DocTypeVersion.Modify;
                    end;
                  end else begin
                    if not DocTypeVersion.FindFirst then
                      if not Confirm(Text002) then
                        Error('');
                  end;
                end;
            end;
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Code","Sender ID","Version No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        MapTableLine.SetRange("Document No.",'');
        MapTableLine.SetRange("Doc. Type Code",Code);
        MapTableLine.SetRange("Sender ID","Sender ID");
        MapTableLine.SetRange("Version No.","Version No.");
        MapTableLine.DeleteAll(true);
    end;

    var
        DocTypeVersion: Record "GIM - Document Type Version";
        Text001: Label 'Base version allready exists for this document type. Do you want to set this version as new base version?';
        Text002: Label 'This will make current document type without base version. Do you want to continue?';
        MapTableLine: Record "GIM - Mapping Table Line";
}

