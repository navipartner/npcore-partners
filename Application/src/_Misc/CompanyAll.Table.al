table 6014441 "NPR Company All"
{
    Caption = 'Company All';
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; Company; Text[50])
        {
            Caption = 'Company';
            TableRelation = Company.Name;
            DataClassification = CustomerContent;
        }
        field(2; Afdeling; Code[10])
        {
            Caption = 'Department';
            DataClassification = CustomerContent;
        }
        field(3; "npc - Company No."; Code[20])
        {
            Caption = 'Company No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                npc_remote.ChangeCompany(Company.Name);
                if npc_remote.Get() then begin
                    npc_remote."Company No." := "npc - Company No.";
                    npc_remote.Modify();
                end;
            end;
        }
        field(4; "icomm - NAS Enabled"; Boolean)
        {
            Caption = 'iComm - NAS Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                icomm_remote.ChangeCompany(Company.Name);
                if icomm_remote.Get() then begin
                    icomm_remote."NAS - Enabled" := "icomm - NAS Enabled";
                    icomm_remote.Modify();
                end;
            end;
        }
        field(5; "npc - Sales posting"; Boolean)
        {
            Caption = 'NPC - Sales Posting';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                npc_remote.ChangeCompany(Company.Name);
                if npc_remote.Get() then begin
                    npc_remote."Post Sale" := "npc - Sales posting";
                    npc_remote.Modify();
                end;
            end;
        }
        field(6; "npc - Immediate postings"; Option)
        {
            Caption = 'Immediate posting';
            OptionCaption = ' ,Serial no.,Always';
            OptionMembers = " ","Serial no.",Always;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                npc_remote.ChangeCompany(Company.Name);
                if npc_remote.Get() then begin
                    npc_remote."Immediate postings" := "npc - Immediate postings";
                    npc_remote.Modify();
                end;
            end;
        }
    }

    keys
    {
        key(Key1; Company, Afdeling)
        {
        }
    }

    var
        company: Record Company;
        icomm_remote: Record "NPR I-Comm";
        npc_remote: Record "NPR Retail Setup";
}

