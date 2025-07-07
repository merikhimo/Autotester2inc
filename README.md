# Inno Test
![Logo](./Assests/logo.jpg)

### One line description
Automatically check websites using custom test cases — simple, fast, and without programming skills.

### Link to the Demo Video
https://drive.google.com/file/d/1QEE76XP4mnRaU0ynXxHeObb-Hm-ILD3P/view?usp=sharing

### Link to product
http://31.129.111.114:8080/

### Project Goal(s) and Description
The goal of the project is to create a simple and accessible tool for checking websites for basic interface elements such as fields, buttons, and headings. The user enters a URL and specifies what needs to be checked, and the system runs an automated test and provides a result in the form of ✅/❌ for each question.

## Development

## Roadmap

- [x] **MVP-0**
  - [x] Interface Layout (Figma)  
  - [x] User scenario elaboration  
  - [x] Without working logic  

- [x] **MVP-1**
  - [x] Front-to-back communication  
  - [x] DOM parsing and checking by conditions  
  - [x] Adding test steps (+)  
  - [x] Entering URLs and conditions  

- [ ] **MVP-2**
  - [ ] Templates for tests  
  - [ ] Generating conditions through **AI**

- [ ] **MVP-3**
  - [ ] Export results in PDF format  
  - [ ] UI/UX testing with users


### Kanban board

We use a GitLab Issue Board with the following columns:

- To Do  
  _Entry criteria:_
    - Issue is estimated
    - Issue uses the defined template
    - Label To Do is applied

- In Progress  
  _Entry criteria:_
    - A new branch is created for the issue
    - Assigned to a team member

- In Review  
  _Entry criteria:_
    - Merge request is created
    - Reviewer is assigned

- Ready to deploy  
  _Entry criteria:_
    - Review is complete
    - MR is approved

- User Testing  
  _Entry criteria:_
    - Feature is deployed to staging
    - Customer is informed and test scenario is ready

- Done  
  _Entry criteria:_
    - All acceptance criteria are met
    - Feedback (if any) is resolved
    - Issue is closed

### Git workflow

Each developer created custom CI Pipeline files in the .github/workflows directory.
More details in "Build and deployment" section

We follow a simplified GitHub Flow.
- All development is done on other branches from `main`.
- Branches are named according to developer tasks

**Issue templates**: We use templates for:
- User Story
- Bug Report
- Technical Task

  TODO: IMPLEMENT TEMPLATES AND ADD A LINK TO THEM HERE

**Commit format**:  
Each developer describes what have he done in the commit

**Pull Requests**:
https://github.com/cQu1x/Autotester/pulls?q=is%3Apr+is%3Aclosed

**Code review**:
Each pull request must be reviewed by at least one other team member before merging.

**Git workflow diagram**

TODO: IMPLEMENT GITGRAPH DIAGRAM

## Quality assurance

### Quality attribute scenarios

See
```
docs/quality-assurance/quality-attribute-scenarios.md
```


### Automated tests

Flutter:
- Used in-build flutter tools for testing
- Implemented unit-tests for widgets
- `frontend/test` contains all tests

## Build and deployment

### Continuous integration

Flutter CI:
- Link to CI: https://github.com/cQu1x/Autotester/blob/main/.github/workflows/flutter_ci.yml
- Downloads flutter
- Runs tests
- Creates build for web application (important for code updates)

Golang:
 - Used in-build golang tools for testing
 - Implemented unit test for cookies and validators. Implemented integration tests for handlers
 - `tests/` contains all tests

Golang CI:
 - Link to CI: https://github.com/cQu1x/Autotester/actions/workflows/go-ci.yml
 - Downloads Golang
 - Runs tests and linting

Python:
 - Used python libraries (pytest) for testing
 - Implemented tests for parser and LLM-connection
 - `/test_1.py` contains all tests

Python CI:
 - Link to CI: https://github.com/cQu1x/Autotester/actions/workflows/python-ci.yml
 - Downloads Python
 - Runs tests


Link to architecutre README:
https://github.com/cQu1x/Autotester/tree/main/internal

### MIT Licence:
https://github.com/cQu1x/Autotester/blob/main/LICENSE
