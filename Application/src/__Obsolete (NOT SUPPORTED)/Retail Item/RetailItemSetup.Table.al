table 6014466 "NPR Retail Item Setup"
{
    Access = Internal;
    Caption = 'Retail Item Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Item Group on Creation"; Boolean)
        {
            Caption = 'Item Group On Creation';
            DataClassification = CustomerContent;
            Description = 'Angiver om der skal sp¢rges efter vgr. ved oprettelse';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(20; "Item Description at 1 star"; Boolean)
        {
            Caption = 'Item Description At *';
            DataClassification = CustomerContent;
            Description = 'Overf¢rer varebeskrivelse fra varegruppe ved autoopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(24; "Autocreate EAN-Number"; Boolean)
        {
            Caption = 'Autocreate EAN-Number';
            DataClassification = CustomerContent;
            Description = 'Opret EAN nummer  ved ny vare';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(25; "EAN-No. at Item Create"; Boolean)
        {
            Caption = 'EAN-No. At Item Create';
            DataClassification = CustomerContent;
            Description = 'Autoopret EAN nummer ved vareopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(30; "EAN No. at 1 star"; Boolean)
        {
            Caption = 'EAN No. At *';
            DataClassification = CustomerContent;
            Description = 'Lav EAN nummer ved vare autoopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(40; "Transfer SeO Item Entry"; Boolean)
        {
            Caption = 'Transfer Seo To Item Entry';
            DataClassification = CustomerContent;
            Description = 'Overf¢rsel af Serienummer ej oprettet til varepost';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(50; "Itemgroup Pre No. Serie"; Code[5])
        {
            Caption = 'Itemgroup Pre No. Serie';
            DataClassification = CustomerContent;
            Description = 'Code f¢r automatisk oprettede varegruppe nr. serier';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(60; "Itemgroup No. Serie StartNo."; Code[20])
        {
            Caption = 'Itemgroup No. Serie StartNo.';
            DataClassification = CustomerContent;
            Description = 'Startnummer til varegruppe nr. serie';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(70; "Itemgroup No. Serie EndNo."; Code[20])
        {
            Caption = 'Itemgroup No. Serie EndNo.';
            DataClassification = CustomerContent;
            Description = 'Slutnummer til varegruppe nr. serie';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(80; "Itemgroup No. Serie Warning"; Code[20])
        {
            Caption = 'Itemgroup No. Serie Warning';
            DataClassification = CustomerContent;
            Description = 'Advarselsnummer til varegruppe nr. serie';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(90; "Reason for Return Mandatory"; Boolean)
        {
            Caption = 'Reason For Return Mandatory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(100; "Description Control"; Option)
        {
            Caption = 'Description Control';
            DataClassification = CustomerContent;
            OptionCaption = '<Description>,<Description 2>,<Vendor Name><Item Group><Vendor Item No.>,<Description 2><Item Group Name>,<Description><Variant Info>,<Description Item>:<Description 2 Variant>';
            OptionMembers = "<Description>","<Description 2>","<Vendor Name><Item Group><Vendor Item No.>","<Description 2><Item group name>","<Description><Variant Info>","<Desc Item>:<Desc2 Variant>";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(110; "Not use Dim filter SerialNo"; Boolean)
        {
            Caption = 'Dont Use Dim Filter Serial No.';
            DataClassification = CustomerContent;
            Description = 'Skip filtering in global Dimension when searching for SerialNo in ItemLedger';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
