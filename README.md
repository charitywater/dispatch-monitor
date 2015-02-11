# charity: water – Remote Monitoring

## Development Setup

### Requirements

- Ruby 2.1.2
- Postgres 9.3
- Redis
- PhantomJS

### Instructions

Copy `config/database.yml.example` to `config/database.yml` and update it to
match your database.

Copy `.env.example` to `.env`. The following keys will be added, update them as
needed:

```bash
FLUID_SURVEYS_HOST=charitywater.fluidsurveys.com:443
FLUID_SURVEYS_USER=<your FluidSurveys email address>
FLUID_SURVEYS_PASSWORD=<your FluidSurveys password>
FLUID_SURVEYS_LIMIT=200   # Number of survey responses per request. Max: 200.
GOOGLE_MAPS_API_KEY=<your Google Maps API key>
KAMINARI_PER_PAGE=100     # Number of table rows per page.
MAIL_DEFAULT_FROM=no-reply@charitywater.org
MAIL_DEFAULT_TO=test@example.com
WAZI_APP_ID=<your WAZI app id>
WAZI_HOST=<WAZI host address>
WAZI_SECRET=<your WAZI secret>
WAZI_VERIFY_SSL=true # Set to false in development
SECRET_KEY_BASE=<your Rails default secret key base>
```

To start the app, run:

```sh
bundle
gem install foreman
foreman start
```

### 3rd-party Instructions

We use the following:

* [Foundation][foundation] is our CSS framework (with Compass). Check out
  `foundation_and_overrides.css.scss` for customizations.
* [ElementalJS][elementaljs] helps us bind JavaScript behaviors to specific DOM
  elements.
* [Embedded JavaScript][ejs] is how we generate dynamic JavaScript templates.
* [Devise][devise] provides our authentication.
* [Pundit][pundit] powers our authorization.

[devise]: https://github.com/plataformatec/devise
[ejs]: http://embeddedjs.com/
[elementaljs]: https://github.com/elementaljs/elementaljs
[foundation]: http://foundation.zurb.com/docs/
[pundit]: https://github.com/elabs/pundit

## Testing

To test the app, just run `rake`. This will run:

1. License Finder, to ensure that we have clearance to use our dependencies.
2. Brakeman, our security / vulnerability test.
3. RSpec, our primary test suite.
4. JSLint, our JavaScript code validator.
5. Jasmine, our JavaScript test suite.

### Testing strategy

We do test-driven development. This means that we write failing tests first,
then we write code to make those tests pass, then we refactor that code.

When developing a new feature, we start with coarse-grain feature tests. These
UI-based tests do not handle every possible condition, but serve to drive out
the initial code.

Then, we write unit tests. When the feature test requires a new class, such as
a new controller, we create the new class and the corresponding unit test.
After we bring that class through the red-green-refactor cycle, we return to
the feature to continue to the next step of the feature. This, in turn, will
drive out a new class or a new method to continue the cycle.

To test integrations with 3rd-parties and all possible cases for critical
functions (like authorization), we write integration tests. They generally hit
live instances of the services and ensure that the app behaves appropriately.
We use VCR to record these external requests and responses to speed up the test
suite.

We've put some effort in trying not to hit the database whenever possible. Only
feature and model specs do so.

## Deploying

Both staging and production are hosted on Heroku. We use the gem [heroku_san][]
to easily deploy the application to Heroku.

Primarily, we deploy after the build has passed in CI. Using Semaphore,
navigate to the successful build, click the 'Deploy Manually' link, and select
your desired environment.

![Semaphore screenshot](https://cloud.githubusercontent.com/assets/7408703/3559138/ba132588-0945-11e4-9298-a0237b391b8d.png)

If you find it necessary to deploy directly to Heroku without going through
Semaphore, something must have gone horribly wrong. Contain your rage, then run
`rake <environment> deploy(:force)`, where `<environment>` is `staging` or
`production`.

There are other commands provided by `heroku_san` that we frequently use. We
particularly enjoy:

```bash
rake <environment> console
rake <environment> logs:tail
```

### Scheduled Jobs

After deploying, if you want to add a new rake task to the scheduled jobs, you
can do it through [Heroku Scheduler][heroku_scheduler]. As of 2014/07/29, these
are the scheduled jobs:

```bash
rake survey_response_import:both_types[source_observation_v1:source_observation_v02,maintenance_report_v02]
rake survey_response_import:remove_deleted
```

[heroku_san]: https://github.com/fastestforward/heroku_san
[heroku_scheduler]: https://dashboard.heroku.com/orgs/charity-water/apps/cw-monitoring-staging/resources

## Development

### Filtering a View by Program

We have a developed a generic solution for filtering a view by multiple
parameters.

For example, you might want to view every project in Ethiopia, or
every project that is broken, or every broken project in Ethiopia. Perhaps you
want to view the 3rd page of every broken project in Ethiopia.

Our generic solution is a `FilterForm`. It wraps the query parameters and it
provides the correct program based on the submitted parameters. Then, a list
object, like `ProjectList` will use the `FilterForm` to figure out the rest of
the filters to apply.

### How we show projects on Google Maps

We use ElementalJS to load the map behavior. There's two flavors: a 'Project
Map' and a 'Dashboard Map'. The Dashboard Map will load all projects that are
visible to the user (based on their access) but has no interaction capability.
The Project Map has some additional interactions to support filtering and
selecting a project.

A map can be centered based on a project's latitude and longitude or based on a
given set of bounds. The projects that are visible to the user and are within
the bounds will then be loaded.

When you click on a project on the map, a custom event is triggered. Another
behavior then loads the project details in the map sidebar.

Filtering in the map works by grouping the map Markers in a MarkerLayer based
on project status. When the status filter is changed, a custom event is
triggered. A separate behavior will then tell each MarkerLayer to show or hide
their project Markers.

### Adding a new version of an existing survey type

#### Overview

1. Clone your survey on FluidSurveys into a new, test version.
2. Represent the `Structure` of the new survey version.
3. Add the new `Structure` class to the `Resolver`.
4. Add the new survey version to the `SurveyResponse` model.
5. Capture business logic changes in the `SurveyPolicy` and new
   `PostProcessors`.
6. Add manual import buttons.
7. Add survey version to nightly import tasks.
8. Add section title for nightly import email.
9. Add new FluidSurveys webhooks.
10. Add integration tests.

#### Details

1. Clone your survey on FluidSurveys into a new, test version. This will allow
you to submit as many survey responses as you need to test your new integration
without actually affecting live data and statistics.  Ensure that the new name
has the words _TEST_ and _LOOKOUT_ (_e.g. TEST for LOOKOUT: Source Observation
V.02_).

  Consider the following steps for both the test and the live versions of the new
survey. Of course, you will perform all of these steps by writing your tests
first.

2. Create a new `FluidSurveys::Structure::<SurveyType><NewVersion>` class that
subclasses from `FluidSurveys::Structure::Base` to take care of parsing the
survey's structure. Note that `Base` has the shared functionality between
survey types and versions.

  All survey responses from FluidSurveys use a unique key to
represent each question. The app needs to understand which key or keys belong
to each question. We use the `FluidSurveys::Structure::<SurveyType><Version>`
classes to convert each survey's keys back into questions. For example, v1 of
the source observation survey stores its deployment code under the `icJ0bt2hs1`
key, while v02 uses 7 different keys to represent the deployment code. The
`SourceObservationV1` and `SourceObservationV02` classes take care of
determining how to parse the deployment code structure.

3. The app uses a Ruby symbol to represent each survey type and version. The
`FluidSurveys::Structure::Resolver` converts between symbol and the
corresponding `Structure`. Define a `survey_type` class method in your new
`FluidSurveys::Structure::<SurveyType><NewVersion>` with the symbol
representing the new survey version (refer to
`FluidSurveys::Structure::SourceObservationV1` for an example). Then, add your
`FluidSurveys::Structure::<SurveyType><NewVersion>` to the `type_to_class_map`.

4. Add the new symbol to the SurveyResponse model in either
`self.source_observation_types` or `self.maintenance_report_types`. These are
used throughout the app whenever functionality must differ between survey
types.

5. If the new survey version requires a change of business logic (_e.g._
changing when a ticket is created), capture that change in the
`RemoteMonitoring::PostProcessor::SurveyPolicy`. Consider adding a new
`PostProcessor` to handle any new actions required.

  Whenever the app receives a new survey response or a new sensor reading,
several actions must be performed. For example, when repairs were unsuccessful,
a notification email must be sent (among other actions). This action is
represented by the
`RemoteMonitoring::PostProcessor::RepairsUnsuccessfulEmailSender`.

  ```ruby
  class RepairsUnsuccessfulEmailSender
    def process(policy)
      return unless policy.send_repairs_unsuccessful_email?

      RemoteMonitoring::JobQueue.enqueue(
        Email::RepairsUnsuccessfulJob,
        policy.survey_response.id
      )
    end
  end

  class SurveyPolicy
    # ... other methods ...

    def send_repairs_unsuccessful_email?
      from_webhook? && maintenance_report_processable? && try_repairs_again?
    end
  end
  ```

6. To be able to manually trigger a full import of the new survey version, add new
buttons to the `Import::Surveys#new` view for both live and test versions.
Ensure that the button for the test version is not shown in production.

7. In [Heroku Scheduler][heroku_scheduler], add the new survey version to the
`both_types` task. Refer to the [Scheduled Jobs](#scheduled-jobs) section for
more information. Ensure that the test version is not scheduled in production.

8. When the bulk import is run, a new section will be added for you in the email
with the import results of the new survey version. Specify a title for this
section in `config/locales/en.yml` under `en.application.mailer`.

9. Add a new FluidSurveys webhook to staging and to production for the new survey
version. The app will be notified whenever a new survey response is submitted
to FluidSurveys. Refer to the [FluidSurveys](#fluidsurveys) section for more
information. Ensure that a production webhook is not added for the test
version.

10. We hope that any required spec changes will be in obvious locations.
Nonetheless, we would like to suggest that you add your new version to the
following integration specs:

  - `spec/integration/tasks/survey_response_import/<survey_type>_spec.rb`
  - `spec/integration/webhook/survey_responses_spec.rb`

### Adding a new survey type

This one will be trickier. Both the Source Observation survey and the
Maintenance Report survey have the same structure, serve similar purposes, and
can be handled through the same pipeline. Since, at the time of this writing,
we do not know what new information you will be processing, this information
will be more generic.

#### Overview

Please consider the actions to add a new survey version. In addition,
consider the following actions:

1. Add a new entry in the `SurveyResponse` model with methods for the new survey
   type.
2. Add new methods in the `Import::Survey` and `Webhook::SurveyResponse` models,
   to include the new types in the scheduled import jobs on staging and on
   production.
3. Add a new `Import::<NewSurvey>Job` for the webhook import.
4. Add a new `Import::<NewSurveys>Job` for the nightly bulk import.
5. For each of those jobs, add a new importer in
   `RemoteMonitoring::SurveyImporting`.
6. For each of those jobs, add a new mailer. Usually the bulk sends a full
   report and the webhook sends a notification about that one event, if the
   event is relevant.
7. Add integration tests.

For further detail, please refer to the implementation of the Source
Observation surveys import (starts at `Webhook::SurveyResponsesController`).

### Pipeline for Importing a Survey Response

#### Webhook
![Pipeline for Importing a SurveyResponse via Webhook](https://cloud.githubusercontent.com/assets/7408703/3912950/7acd25a4-2330-11e4-8e28-1990df8b0d49.png)

#### Nightly Bulk Import

![Pipeline for Importing a SurveyResponse via Nightly Bulk Import](https://cloud.githubusercontent.com/assets/7408703/3913160/da8838c4-2332-11e4-8bb3-93df13ee4056.png)

## External Services

### FluidSurveys

We use FluidSurveys to collect information about our water points. When field
workers visit a water point, they record the water point's conditions by
filling out a survey. When FluidSurveys receives a new survey response, it
will notify this app via a previously subscribed webhook.

To connect to FluidSurveys, the `FluidSurveys::Client` needs the following
environment variables:

```sh
FLUID_SURVEYS_HOST=charitywater.fluidsurveys.com:443
FLUID_SURVEYS_USER=<the_user@example.com>
FLUID_SURVEYS_PASSWORD=<yourpassword>
FLUID_SURVEYS_LIMIT=200
```

To list the existing webhooks:

```sh
rake fs:webhooks
```

To subscribe to a survey's webhook:

```sh
rake fs:subscribe[callback_url,survey_type]
```

To unsubscribe from a webhook:

```sh
rake fs:unsubscribe[callback_url]
```

Additionally, we have a fallback rake task scheduled as a cron-like job every
evening. The task asks FluidSurveys for every survey response for every survey.

To run this task manually:

```sh
rake survey_response_import:both_types[source_observation_v1:source_observation_v02(:additional_source_observation_types...),maintenance_report_v02(:additional_maintenance_report_types...)]
```

Use a comma character to separate the source observation types from the
maintenance report types. Use a colon character to separate each type.
Unfortunately, `rake` does not permit whitespace.

Finally, we have another rake task scheduled every evening to remove from our
database any survey response that has been deleted from FluidSurveys.

To run this task manually:

```sh
rake import:survey_response:remove_deleted
```

Generally, our staging app is subscribed to both live and test versions of each
survey type, while our production app is only subscribed to live versions.

### Sensors

The sensor integration has been built off of the spec instead of actual packets
received. The sensors are supposed to hit the `/sensors/receive` endpoint. As
of the time of this writing, there are no physical sensors to use
for testing.

Each sensor will send a weekly message primarily containing the quantity of
liters drawn every hour for that week. The sensor will also send an immediate
'red flag' message when it detects an anomaly. It will only send one of these
and then resume normal delivery of weekly messages. We receive these messages
as JSON from BodyTrace.

### GPS with GlobalStar

The app receives regular updates from field vehicles such as drilling rigs. The
app logs the response and forwards the decoded payload to WAZI.

GlobalStar sends an XML message to the `/gps/receive` endpoint. The primary
element of the XML is the `<payload>0xAF19...</payload>` element. There are
documents in Pivotal Tracker to help decode the hexadecimal payload. If you
need these, may God have mercy on your soul.

### Google Maps

Using an API key enables you to monitor your application's Maps API usage, and
ensures that Google can contact you about your application if necessary If the
app generates [25,000 map loads or more each day for 90
days][google_maps_usage], Google will contact you to ask for payment. However,
Google states that apps that in the public's benefit will be allowed access
free-of-charge.

To add your Google Maps API key, define the `GOOGLE_MAPS_API_KEY` environment
variable.

[google_maps_usage]: https://developers.google.com/maps/documentation/javascript/usage#usage_limits

### WAZI

The app requests project details from WAZI using the `/projects/search/`
endpoint. A project import can be triggered by an admin through the app. The
app also sends GPS information to the wazi gps endpoint.

### Heroku Plugins

* Heroku Postgres is our database.
* Heroku Scheduler handles our nightly tasks.
* New Relic measures server response time, database load, error rate, etc.
* [PG Backups][pg_backups] takes daily backups of the database with a week's retention. 
  It also takes weekly backups with a month's retention.
* Papertrail stores the application's logs with a searchable interface.
* Redis To Go is used by Resque to handle all of our background jobs.
* SSL ensures we use HTTPS.
* SendGrid sends emails for us.
* Sentry captures and reports application exceptions with insights and trends.

[pg_backups]: https://addons.heroku.com/pgbackups#auto-month

## Business Logic

### Changing a Project's Status

![Flowchart illustrating processes for when a Source Observation survey is received](https://cloud.githubusercontent.com/assets/7408703/3727700/cf8aaaa4-16a0-11e4-8320-ae303dfe6507.png)

![Flowchart illustrating processes for when a Maintenance Report survey is received](https://cloud.githubusercontent.com/assets/7408703/3727702/d14ce550-16a0-11e4-89cd-76510c1f86ab.png)

*The sources for these flowcharts are stored in [Gliffy](https://www.gliffy.com).*
