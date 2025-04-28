#if not (BC17 or BC18 or BC19 or BC20 or BC21)
enumextension 6014421 "NPR Email Connector" extends "Email Connector"
{
    value(6014400; "NPR NP Email Web SMTP")
    {
        Caption = 'NP Email';
        Implementation = "Email Connector" = "NPR NP Email Connector";
    }
}
#endif