package App::DarkPAN::Command::repo::accept;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny     ();
use Dist::Metadata ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

sub command_names { 'repo/accept' }

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'dry-run', 'List the staged modules, but do not accept them' ],
        [],
        $class->SUPER::opt_spec,
    )
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $root = Path::Tiny::path( $opt->root );

    die "Not a DarkPAN repository: $root"
        unless -d $root->child('CPAN')
            && -d $root->child('DBOX');

    my $modlist = App::DarkPAN::Model->JSON->decode( 
        eval { 
            $root->child('DBOX')
                 ->child('modlist.json')
                 ->slurp 
        } // '[]'
    );

    my $num_modules = 0;
    if ( @$modlist ) {
        $num_modules = scalar @$modlist;
        print "Found $num_modules module(s).\n";
        print $self->generate_data_table( $modlist ), "\n";
        
        if ( $opt->dry_run ) {
            print "[dry-run] Did not accept $num_modules modules into DarkPAN.\n";
        }
        else {
            print "Accepting $num_modules modules into DarkPAN.\n";   
            
            my $m = App::DarkPAN::Model->new( root => $root );
            
            my $cpan     = $root->child('CPAN');
            my $dbox     = $root->child('DBOX');
            
            my $authors  = $m->authors;
            my $packages = $m->packages;
            
            foreach my $module ( @$modlist ) {
                my $in_file  = $dbox->child( $module->{file} );
                my $out_file = $cpan->child( $module->{file} );  
                
                # extract packages entries
                my $meta = Dist::Metadata->new( file => $in_file );
                my $pkgs = $meta->determine_packages;
                
                die 'Could not find any packages in distro ($in_file)'
                    unless scalar keys %$pkgs;
                
                # insert author, as needed
                $authors->insert(
                    { 
                        pauseid => $module->{author}, 
                        name    => 'UNKNOWN', 
                        email   => 'CENSORED' 
                    }
                ) unless $authors->count( 
                    pauseid => $module->{author} 
                );  
                
                # add packages entries, as needed
                foreach my $pkg ( keys %$pkgs ) {
                    # ignore anything inside of t/ 
                    # because that is usually sensible
                    next unless $pkgs->{ $pkg }->{file} !~ /^t\//;
                    
                    print "Inserting $pkg into database associated with $module->{file}\n";
                    # otherwise ...
                    $packages->insert(
                        {
                            package       => $pkg,
                            version       => $pkgs->{ $pkg }->{version} || '',
                            dist_filename => $module->{file},                        
                        }
                    );
                }
                
                # copy the actual file 
                $out_file->parent->mkpath;
                $in_file->move( $out_file );
            }
            
            print "$num_modules module(s) accepted into the DarkPAN.\n";
            
            $root->child('DBOX')
                 ->child('modlist.json')
                 ->spew('[]');
        }
        
    }
    else {
        print "No modules.\n"
    }
}

1;

__END__

# ABSTRACT: Inject modules into a DarkPAN repository

=pod

=head1 DESCRIPTION

=cut
