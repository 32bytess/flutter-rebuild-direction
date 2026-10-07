// GENERATED FIXTURE SKELETON -- spm-fixture-v2
//
// Declarations lifted out of this group's transplants so that ONE fixture serves every role in
// it. That is the point of the file: the same values mount for both endpoints of every
// contrast, so a measured difference is attributable to the edit and not to the scaffolding.
//
// HOW THE VALUES GOT HERE. They are not authored by hand and not invented by the generator.
// Each one is resolved by a pre-registered hierarchy and the rule that fired is recorded, per
// binding, in this group's `fixture_provenance.json`:
//
//   relocated        the value really was in the application; `spm isolate` moved it here
//                    verbatim. Do not "tidy" one -- it is a measurement input.
//   upstream_literal not relocated, but the repository declares it at this group's anchor
//                    commit; taken verbatim, with `file@sha` recorded.
//   protocol_constant neither of the above; the committed table in `config/fixture_policy.json`.
//                    Collection cardinality is one declared constant, corpus-wide.
//   maximal_branch   a bool/enum/nullability that decides WHICH subtree renders takes the arm
//                    that renders more. This one OVERRIDES a relocated value, and says so.
//
// WHAT REMAINS TRUE REGARDLESS OF WHO OR WHAT FILLS A SLOT:
//
//   * The same values serve every role in the group. That is what makes the stubbing
//     symmetric across a pair, which is what makes a measured difference attributable to
//     the edit rather than to the scaffolding.
//   * Fixed collection cardinality. A list of 3 in one place and 10 in another is a change
//     in tree size, and tree size is the dependent variable.
//   * Deterministic values only: no `Random`, no `DateTime.now()`, no I/O, no network, no
//     animation controllers left ticking.
//   * Keep `extends` and `implements` clauses exactly as they are. `spm analyze` decides
//     widget versus value object by walking the supertype chain, so a stand-in that stops
//     extending its widget base silently moves allocations into `valueObjectAllocCount`.
//   * Fill before measuring, then freeze. A fixture edited after seeing a result is a
//     fixture the result cannot be defended against.
//
// A slot the hierarchy cannot resolve keeps its `// TODO: value` and is NOT guessed.
// `scripts/fixture_gate.py` then refuses the group, so an unfilled fixture cannot reach the
// device.
//
// This file is a pure function of the mine plus two committed tables, and is regenerated as
// long as it is untouched. The first HAND edit makes it yours: the screen sees the file no
// longer matches the hash it recorded, copies it into config/authored_fixtures/, and never
// generates over it again -- including after a prune deletes this directory, which is how
// the hash alone used to lose an edit. `scripts/authored_fixtures.py --list` says which
// groups the corpus no longer derives from the mine; `--release <group>` hands one back.
// ignore_for_file: unused_import, unused_element, unused_field
part of generated_widget;


// SEEDS -- the values the generated `initState` reads, for which `spm isolate`
// could build none. It declares each of these `late` and leaves it unassigned on
// purpose: a fabricated default would be measured as though it were the value that
// was really there. Assign one below and every role in this group gets it.

// HAND-AUTHORED. The anchor worktree for `SrS2225a/custom_uploader` is no longer on
// disk, so no `upstream_literal` could be taken; these are plausible values for a saved
// FTP destination in a ShareX-style uploader. The screen is the edit form for one
// share, so non-null is both the realistic state and the arm `maximal_branch` takes.
// No `build` body in this group reads `editor` -- the revs carry a hardcoded "FTP"
// label -- so the record is inert for measurement. It exists so `initState` has a value
// to read, and so the controllers below carry one consistent set of strings.
// The bool and the nullable slot keep what the stand-in declares: a bool and a
// nullability decide WHICH subtree renders, and those are not mine to move.
late NetworkShare? fixtureEditor = NetworkShare(
  protocol: 'ftp://',
  domain: 'files.example.com',
  username: 'uploader',
  password: 'n0t-a-real-passw0rd',
  folderPath: '/srv/uploads/screenshots',
  port: 21,
  selected: false, // branch-deciding bool, untouched
  urlPath: null, // branch-deciding nullability, untouched
);

// LIFTED BINDINGS -- the scope's initial state, which `spm isolate` 0.7.0 moves out
// of the application and into a fixture block of its own. Most of these carry the
// value that was really there, relocated rather than invented, and are reproduced
// here verbatim: do not "tidy" one, it is a measurement input.
//
// The ones marked TODO are the exception. Where the binding came from the
// application and no value existed to move, the block gets an empty collection or a
// null, and how many elements you put in one IS tree size -- the dependent variable.
// That is a decision, and it is why they are hoisted: filled in once here, the whole
// group mounts from identical values, so a measured difference is attributable to
// the edit rather than to the scaffolding.

GlobalKey<FormState> fixtureFormKey = GlobalKey<FormState>();

// Seeded with `text:` so the six `TextFormField`s mount showing the share above
// instead of blank. Only the controller's content changes: the same one controller is
// still allocated here and handed to the same one field, so no widget is added, moved
// or removed, and nothing the analysis counts moves with it.

TextEditingController fixtureDomainController = TextEditingController(
  text: 'files.example.com',
);

TextEditingController fixtureUsernameController = TextEditingController(
  text: 'uploader',
);

TextEditingController fixturePasswordController = TextEditingController(
  text: 'n0t-a-real-passw0rd',
);

TextEditingController fixtureFolderPathController = TextEditingController(
  text: '/srv/uploads/screenshots',
);

TextEditingController fixturePortController = TextEditingController(text: '21');

TextEditingController fixtureUrlPathController = TextEditingController(
  text: 'cdn.example.com/screenshots',
);

// Relocated, and the `value:` of the protocol `DropdownButtonFormField` -- it has to
// stay one of the four declared items. Untouched.
String fixtureSelectedProtocol = 'ftp://';

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppLocalizations {
  AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get custom_uploader => 'Custom uploader';
  dynamic get github => 'GitHub';
  dynamic get donate => 'Donate';
  dynamic get help => 'Help';
  dynamic get no_file_selected => 'No file selected';
  dynamic get no_custom_uploaders => 'No custom uploaders yet';
  dynamic get before_you_can_upload_files =>
      'Add an uploader before you can upload files';
  dynamic get uploading => 'Uploading';
  dynamic get choose_files => 'Choose files';
  dynamic get ok => 'OK';
  dynamic get delete_this_share => 'Delete this share?';
  dynamic get yes => 'Yes';
  dynamic get no => 'No';
  dynamic get view_logs => 'View logs';
  dynamic get ftp_not_supported => 'FTP is not supported on this platform';
  dynamic get no_uploader_selected => 'No uploader selected';
  dynamic get import_from_file => 'Import from file';
  dynamic get export_to_file => 'Export to file';
  dynamic get edit => 'Edit';
  dynamic get logs_downloaded_successfully => 'Logs downloaded successfully';
  dynamic get failed_to_export => 'Failed to export';
  dynamic get failed_to_import => 'Failed to import';
  dynamic get no_logs_available => 'No logs available';
  dynamic get custom_uploader_logs => 'Custom uploader logs';
  dynamic get download_logs => 'Download logs';
  dynamic get clear_logs => 'Clear logs';
  dynamic get error_loading_logs => 'Error loading logs';
  dynamic get advanced => 'Advanced';
  dynamic get save => 'Save';
  dynamic get cancel => 'Cancel';
  dynamic get test => 'Test';
  dynamic get connection_successful => 'Connection successful';
  dynamic get connection_failed => 'Connection failed';
  dynamic get domain => 'Domain';
  dynamic get username => 'Username';
  dynamic get password => 'Password';
  dynamic get port => 'Port';
  dynamic get remote_folder_path => 'Remote folder path';
  dynamic get protocol => 'Protocol';
  dynamic get url_path => 'URL path';
  dynamic get advanced_view_tip =>
      'Switch to the advanced view to edit headers, parameters and arguments';
  dynamic get use_file_encoding => 'Use file encoding';
  dynamic get share_already_exists => 'A share with that domain already exists';
  dynamic get upload_url_hint => 'https://api.imgur.com/3/image';
  dynamic get upload_url_label => 'Upload URL';
  dynamic get upload_url_error => 'Enter a valid upload URL';
  dynamic get form_data_name_hint => 'image';
  dynamic get form_data_name_label => 'Form data name';
  dynamic get form_data_name_error => 'Enter the form data name';
  dynamic get url_response_hint => r'$json:data.link$';
  dynamic get url_response_label => 'URL response parser';
  dynamic get url_error_response_hint => r'$json:data.error$';
  dynamic get url_error_response_label => 'Error response parser';
  dynamic get method_label => 'Request method';
  dynamic get upload_headers_label => 'Upload headers';
  dynamic get upload_parameters_label => 'Upload parameters';
  dynamic get upload_arguments_label => 'Upload arguments';
  dynamic get failed_to_connect => 'Failed to connect';
  dynamic get upload_success_message => 'Upload complete';
  dynamic get upload_success => 'Upload successful';
  dynamic get upload_failed_unexpectedly => 'Upload failed unexpectedly';
  dynamic get upload_error_unknown => 'Unknown upload error';
  dynamic get import_uploader_already_exists =>
      'That uploader is already imported';
  dynamic get import_uploader_invalid => 'That uploader file is invalid';
  dynamic get import_not_valid_uploader =>
      'The selected file is not a valid uploader';
  dynamic get import_successful => 'Import successful';
  dynamic get export_successful => 'Export successful';
  dynamic get key => 'Key';
  dynamic get value => 'Value';
  dynamic get upload_succeeded_no_url =>
      'Upload succeeded but no URL was returned';
  dynamic get clipboard_copied => 'Copied to clipboard';

  // Every `build` body in this group reads its labels through
  // `AppLocalizations.of(context)!`, so a `null` here is not an empty label -- it is a
  // null check that throws before the first frame. Held in a static final, the way the
  // rest of the corpus stands this class up, so the lookup `build` reaches is a field
  // read and not an allocation.
  static final AppLocalizations _instance = AppLocalizations('en');
  static dynamic of(dynamic context) => _instance;
  dynamic uploadingFile(dynamic current, dynamic fileName, dynamic total) => '';
  dynamic delete(dynamic delete) => '';
  dynamic upload_method_and_type(dynamic method, dynamic type) => '';
  dynamic upload_type_only(dynamic type) => '';
  dynamic permission_denied(dynamic permission) => '';
  dynamic failed_to_download_logs(dynamic error) => '';
  dynamic type_uploader(dynamic type) => '';
  dynamic upload_error_message(
    dynamic status_code,
    dynamic status_message,
    dynamic url,
  ) => '';
  dynamic upload_error_message_with_details(
    dynamic details,
    dynamic status_code,
    dynamic status_message,
    dynamic url,
  ) => '';
  dynamic upload_success_message_with_details(dynamic parsedResponse) => '';
  dynamic upload_error_with_message(dynamic domain, dynamic error) => '';
  dynamic invalid_json(dynamic error) => '';
  dynamic import_request_method_not_supported(dynamic requestMethod) => '';
  dynamic export_failed(dynamic error) => '';
  dynamic platform_not_supported(dynamic platform) => '';
}

class NetworkShare {
  NetworkShare({
    dynamic protocol,
    dynamic domain,
    dynamic username,
    dynamic password,
    dynamic folderPath,
    dynamic port,
    dynamic selected,
    dynamic urlPath,
  });
  // The string and numeric slots of the record, filled so none of them reads blank.
  // No `build` body in this group reaches them -- the revs read the controllers, not
  // the share -- so each one is a single literal on an object `build` never walks.
  dynamic get protocol => 'ftp://';
  set protocol(dynamic _) {}
  dynamic get domain => 'files.example.com';
  set domain(dynamic _) {}
  dynamic get username => 'uploader';
  set username(dynamic _) {}
  dynamic get password => 'n0t-a-real-passw0rd';
  set password(dynamic _) {}
  dynamic get folderPath => '/srv/uploads/screenshots';
  set folderPath(dynamic _) {}
  dynamic get port => 21;
  set port(dynamic _) {}
  // Branch-deciding bool and branch-deciding nullability: left exactly as the
  // stand-in declares them.
  dynamic get selected => false;
  set selected(dynamic _) {}
  dynamic get urlPath => null;
  set urlPath(dynamic _) {}
  void setSelectedShare(dynamic value) {}
}
