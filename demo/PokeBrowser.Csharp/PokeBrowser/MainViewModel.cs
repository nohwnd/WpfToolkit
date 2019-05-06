using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;

namespace PokeBrowser
{
    public class MainViewModel : ViewModelBase
    {
        public MainViewModel()
        {
            Refresh = new RelayCommand(_ => DoRefresh(), _ => true);
            Show = new RelayCommand(_ => DoShow(), _ => _selected != null);

            _client = new HttpClient();
        }

        private ObservableCollection<PokemonLinkViewModel> _pokemonList;
        private ICommand _refresh;
        private PokemonLinkViewModel _selected;
        private ICommand _show;
        private readonly HttpClient _client;
        private PokemonViewModel _detail;
        private Visibility _progressVisibility = Visibility.Hidden;

        public ObservableCollection<PokemonLinkViewModel> PokemonList
        {
            get => _pokemonList;
            set
            {
                _pokemonList = value;
                OnPropertyChanged();
            }
        }

        public PokemonLinkViewModel Selected
        {
            get => _selected;
            set
            {
                _selected = value;
                OnPropertyChanged();
            }
        }

        public ICommand Refresh
        {
            get => _refresh;
            set
            {
                _refresh = value;
                OnPropertyChanged();
            }
        }

        public ICommand Show
        {
            get => _show;
            set
            {
                _show = value;
                OnPropertyChanged();
            }
        }

        public PokemonViewModel Detail
        {
            get => _detail;
            set
            {
                _detail = value;
                OnPropertyChanged();
            }
        }

        public Visibility ProgressVisibility
        {
            get => _progressVisibility;
            set
            {
                _progressVisibility = value;
                OnPropertyChanged();
            }
        }

        private async Task DoRefresh()
        {
            try
            {
                ProgressVisibility = Visibility.Visible;

                
                var url = "https://pokeapi.co/api/v2/pokemon/?limit=300";
                var response = await _client.GetAsync(new Uri(url));
                response.EnsureSuccessStatusCode();

                await Task.Delay(500);

                var s = await response.Content.ReadAsStringAsync();
                var pk = (await response.Content.ReadAsAsync<PokemonJson>()).Results?.OrderBy(o => o.Name).ToList() ??
                         new List<PokemonLinkViewModel>();

                PokemonList = new ObservableCollection<PokemonLinkViewModel>(pk);
                Selected = pk.FirstOrDefault();

                
                
            }
            finally
            {
                ProgressVisibility = Visibility.Hidden;
            }
        }

        private async Task DoShow()
        {
            try
            {
                ProgressVisibility = Visibility.Visible;

                var response = await _client.GetAsync(new Uri(Selected.Url));
                response.EnsureSuccessStatusCode();

                await Task.Delay(500);

                var s = await response.Content.ReadAsStringAsync();
                var p = await response.Content.ReadAsAsync<dynamic>();


                var height = int.Parse(p.height.ToString());
                var weight = int.Parse(p.weight.ToString());
                var name = p.name.ToString();
                var image = p.sprites.front_default.ToString();
                var type = p.types[0].type.name.ToString();

                Detail = new PokemonViewModel
                {
                    Height = height,
                    Weight = weight,
                    Name = name,
                    Image = image,
                    Type = type
                };
            }
            finally
            {
                ProgressVisibility = Visibility.Hidden;
            }
        }
    }
}
