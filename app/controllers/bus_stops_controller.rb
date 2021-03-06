class BusStopsController < ApplicationController
  # GET /bus_stops
  # GET /bus_stops.json

  load_and_authorize_resource

  def index
    if params[:term]
      @bus_stops = BusStop.all(:conditions => ["name ilike ?","%#{params[:term]}%"])
    elsif params[:x1] and params[:y1] and params[:x2] and params[:y1]
      @bus_stops = BusStop.all(:conditions => ["lat BETWEEN ? AND ? AND lng BETWEEN ? AND ?",params[:y1].to_f,params[:y2].to_f, params[:x1].to_f,params[:x2].to_f])
    else
      @bus_stops = BusStop.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bus_stops }
    end
  end

  # GET /bus_stops/1
  # GET /bus_stops/1.json
  def show
    @bus_stop = BusStop.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bus_stop }
    end
  end

  # GET /bus_stops/new
  # GET /bus_stops/new.json
  def new
    @bus_stop = BusStop.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bus_stop }
    end
  end

  # GET /bus_stops/1/edit
  def edit
    @bus_stop = BusStop.get(params[:id])
  end

  # POST /bus_stops
  # POST /bus_stops.json
  def create
    params[:bus_stop][:user_id] = current_user.id
    @bus_stop = BusStop.new(params[:bus_stop])

    respond_to do |format|
      if @bus_stop.save
        format.html { redirect_to @bus_stop, notice: 'Bus stop was successfully created.' }
        format.json { render json: @bus_stop, status: :created, location: @bus_stop }
      else
        format.html { render action: "new" }
        format.json { render json: @bus_stop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bus_stops/1
  # PUT /bus_stops/1.json
  def update
    @bus_stop = BusStop.get(params[:id])

    respond_to do |format|
      if @bus_stop.update(params[:bus_stop])
        format.html { redirect_to @bus_stop, notice: 'Bus stop was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bus_stop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bus_stops/1
  # DELETE /bus_stops/1.json
  def destroy
    @bus_stop = BusStop.get(params[:id])
    @bus_stop.destroy

    respond_to do |format|
      format.html { redirect_to bus_stops_url }
      format.json { head :no_content }
    end
  end
end
