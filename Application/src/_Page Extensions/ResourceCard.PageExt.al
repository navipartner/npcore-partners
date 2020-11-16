pageextension 6014481 "NPR Resource Card" extends "Resource Card"
{
    // NPR5.29/TJ/20161013 CASE 248723 New field E-Mail
    // NPR5.32/TJ/20170519 CASE 275966 New field Over Capacitate Resource
    // NPR5.34/TJ/20170725 CASE 275991 New field E-Mail Password
    // NPR5.38/TJ/20171027 CASE 285194 Removed field "E-Mail Password"
    layout
    {
        addafter("Time Sheet Approver User ID")
        {
            field("NPR Over Capacitate Resource"; "NPR Over Capacitate Resource")
            {
                ApplicationArea = All;
            }
        }
        addafter("Employment Date")
        {
            field("NPR E-Mail"; "NPR E-Mail")
            {
                ApplicationArea = All;
            }
        }
    }
}

