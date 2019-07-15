tableextension 50038 tableextension50038 extends "Marketing Setup" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields   6014400..6014410
    // NPR5.30/TJ  /20170227 CASE 262797 Removed commented code and local Text Constant from Campaign Monitor N.let. Editor - OnLookup()
    fields
    {
        field(6014400;"Campaign Monitor API Key";Text[50])
        {
            Caption = 'Campaign Monitor API Key';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014401;"Campaign Monitor Client Key";Text[50])
        {
            Caption = 'Campaign Monitor Client Key';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014402;"Campaign Monitor N.let. Folder";Text[250])
        {
            Caption = 'Campaign Monitor N.let. Folder';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014403;"Campaign Monitor N.let. Login";Text[20])
        {
            Caption = 'Campaign Monitor N.let. Login';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014404;"Campaign Monitor N.let. Pass";Text[20])
        {
            Caption = 'Campaign Monitor N.let. Pass';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014405;"Campaign Monitor N.let. Editor";Text[250])
        {
            Caption = 'Campaign Monitor N.let. Editor';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014406;"Campaign Monitor Http Folder";Text[250])
        {
            Caption = 'Campaign Monitor Http Folder';
            Description = 'NPR7.100.000/Campaign Monitor';
        }
        field(6014407;"Interaction Log Opens";Code[20])
        {
            Caption = 'Interaction Log Opens';
            Description = 'NPR7.100.000';
            TableRelation = "Interaction Template";
        }
        field(6014408;"Interaction Log Bounces";Code[20])
        {
            Caption = 'Interaction Log Bounces';
            Description = 'NPR7.100.000';
            TableRelation = "Interaction Template";
        }
        field(6014409;"Interaction Log Clicks";Code[20])
        {
            Caption = 'Interaction Log Clicks';
            Description = 'NPR7.100.000';
            TableRelation = "Interaction Template";
        }
        field(6014410;"Interaction Log Unsubscribes";Code[20])
        {
            Caption = 'Interaction Log Unsubscribes';
            Description = 'NPR7.100.000';
            TableRelation = "Interaction Template";
        }
    }
}

