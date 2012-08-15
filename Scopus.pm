=head1 NAME

EPrints::Plugin::Screen::Scopus

=cut

package EPrints::Plugin::Screen::Scopus;

use EPrints::Plugin::Screen;

use constant SEARCH_FORM_ID => "sciverse_search_form";
use constant SEARCH_INPUT_ID => "sciverse_search_string";
use constant RESULTS_CONTAINER_ID => "sciverse";
use constant SPINNER_CONTAINER_ID => "sciverse_spinner";
use constant MORE_CONTAINER_ID => "sciverse_more";
use constant IMPORT_FORM_ID => "sciverse_submit_form";
use constant IMPORT_FORM_TARGET => "/cgi/users/home#t";
use constant ERRORS_CONTAINER_ID => "sciverse_errors";
use constant BUTTON_CLASS => "ep_form_action_button";

@ISA = ('EPrints::Plugin::Screen');

use strict;
use warnings;
use autodie;

=head1 METHODS

=cut

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{appears} = [
        {
            place => "key_tools",
            position => 101
        }
    ];

    return $self;
}

=head2 can_be_viewed

Returns whether current user can view the page this Plugin renders.

=cut

sub can_be_viewed {
    my $self = shift;

    # Only allow users who can create EPrints to view the plug in, as it's for imports.
    return $self->allow("create_eprint");
}

=head2 render

Renders the view, returning HTML.

=cut

sub render {
    my $self = shift;

    my ($session, $user, $html, $elem);

    $session = $self->{session};
    $user = $session->current_user;
    $html = $session->make_doc_fragment;

    $elem = sub { $session->make_element(@_); };

    # Set up search form
    {
        my ($search_div, $search_form, $search_input, $search_submit, $submit_phrase,
            $errors, $errors_box);

        $submit_phrase = $self->html_phrase("searchSubmit")->toString();

        $search_div = $elem->("div",
                              style => "text-align: center");

        $search_form = $elem->("form",
                               name => SEARCH_FORM_ID,
                               id => SEARCH_FORM_ID,
                               action => "");
        $search_input = $elem->("input",
                                type => "text",
                                class => "ep_form_text",
                                name => SEARCH_INPUT_ID);
        $search_submit = $elem->("input",
                                 type => "submit",
                                 class => BUTTON_CLASS,
                                 value => $submit_phrase);
        $search_form->appendChild($search_input);
        $search_form->appendChild($search_submit);
        $search_div->appendChild($search_form);

        $errors = ERRORS_CONTAINER_ID;
        # God, I am not creating separate XML elements for every one of
        # these. Who even does this given the language we are creating is more
        # concise to begin with?
        $errors_box = $session->{xml}->parse_string(qq{
          <div id="sciverse_messages" style="display: none">
            <div class="ep_msg_warning">
              <div class="ep_msg_warning_content">
                <table>
                  <tr>
                    <td>
                      <img alt="Warning" src="/style/images/warning.png"
                                         class="ep_msg_warning_icon" />
                    </td>
                    <td id="$errors">
                    </td>
                  </tr>
                </table>
              </div>
            </div>
          </div>
        });

        $html->appendChild($search_div);
        $html->appendChild($errors_box->documentElement());
    }

    # Set up results container
    {
        my ($container, $results_table, $results_row, $spinner,
            $more, $bottom_bar, $thead);

        $container = $elem->("div",
                             class => "ep_search_results");
        $results_table = $elem->("table",
                                 class => "ep_columns",
                                 cellspacing => "0",
                                 cellpadding => "4",
                                 border => "0",
                                 id => RESULTS_CONTAINER_ID,
                                 style => "display: none",
                                 width => "100%");
        $thead = $elem->("thead");
        $results_row = $elem->("tr",
                               class => "header_plain");

        {
            my (@headers, $th);

            @headers = (" ", "Published", "Title", "Authors", "Source");

            for my $header (@headers) {
                $th = $elem->("th",
                              class => "ep_columns_title");
                $th->appendChild($session->{xml}->create_text_node($header));
                $results_row->appendChild($th);
            }
        }

        $thead->appendChild($results_row);
        $results_table->appendChild($thead);
        $container->appendChild($results_table);

        $bottom_bar = $elem->("div",
                              class => "ep_search_controls_bottom",
                              style => "min-height: 50px; display: none");

        $spinner = $elem->("span",
                           id => SPINNER_CONTAINER_ID);

        $more = $elem->("span",
                        id => MORE_CONTAINER_ID);

        $bottom_bar->appendChild($spinner);
        $bottom_bar->appendChild($more);

        $html->appendChild($container);
        $html->appendChild($bottom_bar);
    }

    # Set up import form
    {
        my ($import_form, $format_input, $screen_input, $form_action);

        # Pretend like we're the normal import form on the Manage Deposits screen.
        $screen_input = $elem->("input",
                                type => "hidden",
                                name => "screen",
                                value => "Import");

        $format_input = $elem->("input",
                                type => "hidden",
                                name => "format",
                                value => "JSON");

        $form_action = $elem->("input",
                               type => "hidden",
                               name => "_action_import_data",
                               value => "Import Items");

        $import_form = $elem->("form",
                               enctype => "multipart/form-data",
                               "accept-charset" => "utf-8",
                               name => IMPORT_FORM_ID,
                               id => IMPORT_FORM_ID,
                               action => IMPORT_FORM_TARGET,
                               method => "post");

        $import_form->appendChild($screen_input);
        $import_form->appendChild($format_input);
        $import_form->appendChild($form_action);

        $html->appendChild($import_form);
    }

    # Add JavaScript to page
    {
        my ($scopus_js, $require_js);

        $scopus_js = $elem->("script",
                             src => "http://api.elsevier.com/javascript/scopussearch.jsp");
        $require_js = $elem->("script",
                              src => "/javascript/libs/require/require.js",
                              "data-main" => "/javascript/scopus_selector");

        $html->appendChild($scopus_js);
        $html->appendChild($require_js);
    }

    return $html;
}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright (c) 2012 The University of Liverpool

=for COPYRIGHT END

=for LICENSE BEGIN

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=for LICENSE END
