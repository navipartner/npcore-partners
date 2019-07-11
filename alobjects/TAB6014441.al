table 6014441 "Company All"
{
    Caption = 'Company All';
    DataPerCompany = false;

    fields
    {
        field(1;Company;Text[50])
        {
            Caption = 'Company';
            TableRelation = Company.Name;
        }
        field(2;Afdeling;Code[10])
        {
            Caption = 'Department';
        }
        field(3;"npc - Company No.";Code[20])
        {
            Caption = 'Company No.';

            trigger OnValidate()
            begin
                npc_remote.ChangeCompany( Company.Name );
                if npc_remote.Get then begin
                  npc_remote."Company No." := "npc - Company No.";
                  npc_remote.Modify;
                end;
            end;
        }
        field(4;"icomm - NAS Enabled";Boolean)
        {
            Caption = 'iComm - NAS Enabled';

            trigger OnValidate()
            begin
                icomm_remote.ChangeCompany( Company.Name );
                if icomm_remote.Get then begin
                  icomm_remote."NAS - Enabled" := "icomm - NAS Enabled";
                  icomm_remote.Modify;
                end;
            end;
        }
        field(5;"npc - Sales posting";Boolean)
        {
            Caption = 'NPC - Sales Posting';

            trigger OnValidate()
            begin
                npc_remote.ChangeCompany( Company.Name );
                if npc_remote.Get then begin
                  npc_remote."Post Sale" := "npc - Sales posting";
                  npc_remote.Modify;
                end;
            end;
        }
        field(6;"npc - Immediate postings";Option)
        {
            Caption = 'Immediate posting';
            OptionCaption = ' ,Serial no.,Always';
            OptionMembers = " ","Serial no.",Always;

            trigger OnValidate()
            begin
                npc_remote.ChangeCompany( Company );
                if npc_remote.Get then begin
                  npc_remote."Immediate postings" := "npc - Immediate postings";
                  npc_remote.Modify;
                end;
            end;
        }
    }

    keys
    {
        key(Key1;Company,Afdeling)
        {
        }
    }

    fieldgroups
    {
    }

    var
        company: Record Company;
        npc_remote: Record "Retail Setup";
        icomm_remote: Record "I-Comm";
}

