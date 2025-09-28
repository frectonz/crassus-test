module Main exposing (main)

import Browser
import Data exposing (countrySalaries)
import Dict
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), usLocale)
import Html exposing (Html, button, div, h1, h2, hr, input, label, option, p, select, span, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)



-- MODEL


type alias Model =
    { salary : Int
    , country : String
    , result : Maybe Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { salary = 0
      , country = ""
      , result = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdateSalary String
    | UpdateCountry String
    | Calculate
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSalary s ->
            let
                cleaned =
                    String.filter Char.isDigit s

                parsed =
                    String.toInt cleaned |> Maybe.withDefault 0
            in
            ( { model | salary = parsed }, Cmd.none )

        UpdateCountry c ->
            ( { model | country = c }, Cmd.none )

        Calculate ->
            if model.salary == 0 || model.country == "" then
                ( model, Cmd.none )

            else
                let
                    annualSalary =
                        toFloat model.salary

                    sixPercent =
                        annualSalary * 0.06

                    avgSalary =
                        Dict.get model.country countrySalaries |> Maybe.withDefault 0

                    legionCost =
                        toFloat (avgSalary * 6000)

                    legions =
                        sixPercent / legionCost
                in
                ( { model | result = Just legions }, Cmd.none )

        Reset ->
            init ()



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "w-screen h-screen mx-auto px-4 py-16 bg-[#f6f2ea] text-[#3f2e2b]" ]
        [ div [ class "text-center mb-16" ]
            [ h1 [ class "text-5xl md:text-7xl font-serif mb-6 text-[#3f2e2b]" ]
                [ text "The Crassus", Html.br [] [], span [ class "text-[#d4a017]" ] [ text "Legion Test" ] ]
            , p [ class "text-xl text-[#6c5e58] max-w-2xl mx-auto" ]
                [ text "Marcus Licinius Crassus believed a man could only consider himself truly rich when his annual income could raise and maintain a Roman legion. Discover your imperial wealth." ]
            ]
        , case model.result of
            Just _ ->
                resultView model

            Nothing ->
                calculatorView model
        ]


calculatorView : Model -> Html Msg
calculatorView model =
    let
        salaryStr =
            if model.salary == 0 then
                ""

            else
                format { usLocale | decimals = Exact 0 } (toFloat model.salary)
    in
    div [ class "mb-12 shadow-lg border-2 rounded-lg bg-[#faf9f6] max-w-4xl mx-auto" ]
        [ div [ class "text-center pb-8 pt-6 px-6" ]
            [ h2 [ class "text-2xl font-serif mb-2 text-[#3f2e2b]" ] [ text "Calculate Your Legions" ]
            , p [ class "text-[#6c5e58]" ] [ text "Enter your annual salary and country to see how many Roman legions you could afford" ]
            ]
        , div [ class "space-y-8 px-6 pb-6" ]
            [ div [ class "grid md:grid-cols-2 gap-6" ]
                [ div []
                    [ label [ for "salary", class "block text-[#3f2e2b]" ] [ text "Annual Salary (USD)" ]
                    , input
                        [ id "salary"
                        , type_ "text"
                        , placeholder "75,000"
                        , value salaryStr
                        , onInput UpdateSalary
                        , class "text-lg h-12 w-full px-3 py-2 border border-[#ddd3c9] bg-[#ffffff] rounded-md focus:outline-none focus:ring-2 focus:ring-[#d4a017]"
                        ]
                        []
                    ]
                , div []
                    [ label [ for "country", class "block text-[#3f2e2b]" ] [ text "Country" ]
                    , select
                        [ id "country"
                        , value model.country
                        , onInput UpdateCountry
                        , class "text-lg h-12 w-full px-3 pr-10 py-2 border border-[#ddd3c9] bg-[#ffffff] text-[#3f2e2b] rounded-md focus:outline-none focus:ring-2 focus:ring-[#d4a017]"
                        ]
                        (option [ value "" ] [ text "Select a country" ]
                            :: (Dict.keys countrySalaries
                                    |> List.map (\c -> option [ value c ] [ text c ])
                               )
                        )
                    ]
                ]
            , button
                [ onClick Calculate
                , disabled (model.salary == 0 || model.country == "")
                , class "w-full h-12 text-lg font-medium rounded-md bg-[#5a3a2b] text-[#faf9f6] hover:bg-[#4a2f23] disabled:opacity-50 disabled:cursor-not-allowed"
                ]
                [ text "Calculate My Legions" ]
            ]
        ]


roundTo10 : Float -> String
roundTo10 n =
    format { usLocale | decimals = Exact 10 } n


currency : Float -> String
currency amount =
    "$" ++ format usLocale amount


resultView : Model -> Html Msg
resultView model =
    let
        annualSalary =
            toFloat model.salary

        sixPercent =
            annualSalary * 0.06

        avgSalary =
            Dict.get model.country countrySalaries |> Maybe.withDefault 0

        legionCost =
            toFloat (avgSalary * 6000)

        legionText =
            case model.result of
                Just r ->
                    "Roman Legion"
                        ++ (if r /= 1 then
                                "s"

                            else
                                ""
                           )

                Nothing ->
                    "No result"
    in
    div [ class "mb-12 bg-[#faf9f6] border border-[#e5d8b3] shadow-lg rounded-lg max-w-4xl mx-auto" ]
        [ div [ class "pt-12 pb-12 px-6 text-center space-y-8" ]
            [ div []
                [ p [ class "text-lg text-[#6c5e58] mb-2" ] [ text "You can raise" ]
                , case model.result of
                    Just r ->
                        h1 [ class "text-7xl font-serif font-bold text-[#d4a017]" ]
                            [ text (roundTo10 r) ]

                    Nothing ->
                        text ""
                , p [ class "text-2xl text-[#6c5e58] mt-4" ] [ text legionText ]
                ]
            , hr [ class "my-8 border-[#ddd3c9]" ] []
            , div [ class "grid md:grid-cols-3 gap-6 text-base text-[#6c5e58]" ]
                [ div []
                    [ p [ class "font-medium text-[#3f2e2b] mb-1" ] [ text "Your 6% Annual Interest" ]
                    , p [ class "text-lg" ] [ text (currency sixPercent) ]
                    ]
                , div []
                    [ p [ class "font-medium text-[#3f2e2b] mb-1" ] [ text "Cost per Legion (6,000 people)" ]
                    , p [ class "text-lg" ] [ text (currency legionCost) ]
                    ]
                , div []
                    [ p [ class "font-medium text-[#3f2e2b] mb-1" ] [ text "Status" ]
                    , p [ class "text-lg font-medium text-[#d4a017]" ]
                        [ text
                            (case model.result of
                                Just r ->
                                    if r >= 1 then
                                        "Wealthy"

                                    else
                                        "Not Quite There"

                                Nothing ->
                                    ""
                            )
                        ]
                    ]
                ]
            , button
                [ onClick Reset
                , class "mt-8 h-12 text-lg font-medium px-8 bg-transparent border border-[#ddd3c9] rounded-md hover:bg-[#d4a017] hover:text-white"
                ]
                [ text "Calculate Again" ]
            ]
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
