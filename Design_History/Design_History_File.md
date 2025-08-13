# Simple Thread Tech Assessment

This document describes my engineering design process while attempting Simple Thread's tech assessment. Parts of this document may not be comprehensive due to time-constraints. In brief, I approach engineering problems starting from user or customer needs and work backwards towards a technological solution. 

# Table of Contents

1. [Observations about the problem](#observations-about-the-problem)
2. [Problem Statement](#problem-statement)
3. [Need Statement](#need-statement)
4. [Literature and Product Review](#literature-and-product-review)
5. [Target Customer](#target-customer)
6. [User Requirements](#user-requirements)
7. [Concept Generation](#concept-generation)
8. [Idea Organization](#idea-organization)
9. [Solution Selection](#solution-selection)
10. [Component Diagram](#component-diagram)
11. [Design Verification](#design-verification)
12. [Design Validation](#design-validation)
13. [Regulatory Aspects](#regulatory-aspects)
14. [Project Abstract](#project-abstract)
15. [Executive Summary](#executive-summary)
16. [References](#references)

## Observations about the problem

A client organization works on multiple professional projects that involve overlapping timelines and travel. These projects involve traveling to both low and high cost of living cities. The organization needs to know how much it should be reimbursed for its work.

Digital reimbursement tracking and calculators exist in many forms. Popular accounting software tools such as QuickBooks allow employees to record, categorize, and review expenses. Other tools such as TripLog focus primarily on recording one type of expense (e.g. mileage) and then integrating with larger accounting suites. Finally, there is a whole nest of time-tracking utilties which allow consultants to easily invoice for time-based work. This camp includes incumbents such as Toggl.

The client organization's reimbursement amounts are not per diem. Instead, reimbursements are calculated according to the following rules:

- A client is reimbursed for a set of projects at a time.
- Any given day is only ever reimbursed once, even if multiple projects are on the same day.
- Projects that are contiguous or overlap, with no gap between the end of one and the start of the next, are considered a sequence of projects and should be treated similar to a single project.
- First day and last day of a project (or sequence of projects) are travel days.
- Any day in the middle of a project (or sequence of projects) is considered a full day.
- If there is a gap between projects, those gap days are not reimbursed and the days on either side of that gap are travel days.
- When projects overlap on the same day, higher reimbursements take priority.

The client will be reimbursed at the following rates:

- A travel day is reimbursed at a rate of 45 dollars per day in a low cost city.
- A travel day is reimbursed at a rate of 55 dollars per day in a high cost city.
- A full day is reimbursed at a rate of 75 dollars per day in a low cost city.
- A full day is reimbursed at a rate of 85 dollars per day in a high cost city.


Use of existing tools like QuickBooks would require manually creating records for every work day while having separate expense categories for the different reimbursement rates. This is an error-prone process as categorization must be set correctly on every record. In addition, a separate "expense" report must be created for each set of projects with the correct filters applied.

This problem is not well served by existing accounting software due to the manual work involved and classification of work reimbursements as expenses. This problem also not well served by existing time-tracking utilties because reimbursement rates are not based on per diem billing.

## Problem Statement

The client organization lacks a system to accurately calculate reimbursements for their multi-project work environment with a complex hierarchy of reimbursement rules.

## Need Statement

Given a set of projects with their corresponding timelines and travel details the client organization needs a specialized tool to accurately calculate project reimbursements.

## Literature and Product Review

## Target Customer

## User Requirements

## Concept Generation

## Idea Organization

## Solution Selection

## Component Diagram

## Design Verification

## Design Validation

## Regulatory Aspects

## Project Abstract

## Executive Summary

## References
