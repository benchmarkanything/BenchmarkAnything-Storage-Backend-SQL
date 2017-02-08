package BenchmarkAnything::Storage::Backend::SQL::Search::MCE;
# ABSTRACT: searchengine support functions using MCE

use MCE::Flow;

=head2 sync_search_engine_mce ($or_sql, $b_force, $i_start, $i_bulkcount)

=over 4

=item $or_sql

The L<BenchmarkAnything::Storage::Backend::SQL|BenchmarkAnything::Storage::Backend::SQL> instance.

=item $b_force

Boolean. Re-sync without check if data already exist in index. Default C<false>.

=item $i_start

First element ID where to start. Default C<1>.

=item $i_bulkcount

How many elements to read and index per bunch. Default C<10000>.

=back

=cut

sub sync_search_engine_mce
{
    my ( $or_sql, $b_force, $i_start, $i_bulkcount) = @_;

    require BenchmarkAnything::Storage::Backend::SQL::Search;

    my $i_count_datapoints = $or_sql->{query}->select_count_datapoints->fetch->[0];

    MCE::Flow::init( chunk_size  => $i_bulkcount,
                     max_workers => 8,
                     bounds_only => 1);
    mce_flow_s sub {
        BenchmarkAnything::Storage::Backend::SQL::Search::_sync_search_engine_process_chunk ($or_sql, $b_force, $_->[0], $_->[1]);
    }, 1, $i_count_datapoints;
}

1;

__END__

=pod

=head1 SYNOPSIS

Inside a method of BenchmarkAnything::Storage::Backend::SQL:

 require BenchmarkAnything::Storage::Backend::SQL::Search::MCE;
 BenchmarkAnything::Storage::Backend::SQL::Search::MCE::sync_search_engine_mce( $or_self, $b_force, $i_start, $i_bulksize);
